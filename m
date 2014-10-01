From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: Why include/net/tcp_states.h is not exported to user-space?
Date: Wed, 1 Oct 2014 14:25:00 -0300
Message-ID: <20141001172500.GH2799@kernel.org>
References: <CAHA+R7MDGKA1Z-1ytk8-+9XaKNcW+kG7UBn8drhdbLJeQYBCyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:40761 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbaJARZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 13:25:05 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7MDGKA1Z-1ytk8-+9XaKNcW+kG7UBn8drhdbLJeQYBCyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 30, 2014 at 11:12:04AM -0700, Cong Wang escreveu:
> These states are needed for user-space to specify ->idiag_states.
> Currently both libnl and ss make their own copy of these definitions.
> Of course, new sock diag is not just limited to TCP, so we probably
> need to rename them to SS_* before exporting them.
> 
> I can send a patch if you agree.

One would have to check what are the current best practices for doing
that, i.e. probably this would have to go via
include/uapi//linux/tcp_states.h? Or take the time and create a new
header for the inet_diag.h stuff as this is not TCP specific for quite a
while?

If you could investigate how to properly expose this and then come back
with a patch proposal I think that would ease reviewing :-)

- Arnaldo
