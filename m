From: Florian Westphal <fw@strlen.de>
Subject: Re: CONFIG_NF_CONNTRACK_PROCFS
Date: Sun, 25 Jan 2015 12:22:09 +0100
Message-ID: <20150125112209.GD13167@breakpoint.cc>
References: <20150125055117.GA5586@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oleg <lego12239@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54465 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488AbbAYLWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 06:22:11 -0500
Content-Disposition: inline
In-Reply-To: <20150125055117.GA5586@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg <lego12239@yandex.ru> wrote:
> net/netfilter/nf_conntrack procfs file is marked as obsolete in the recent
> kernels. What's wrong with it? Or it's simply a new fashion to replace
> simple file interface with anything else?

proc has several drawbacks vs. ctnetlink:
 - not extensible
 - doesn't have ability to query for particular items
 - no add/delete support
 - no event notification (e.g. conntrack -E)
