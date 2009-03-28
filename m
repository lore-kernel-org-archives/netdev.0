From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: Dereferencing freed memory bugs
Date: Sat, 28 Mar 2009 19:18:46 +0100
Message-ID: <49CE6A06.7080008@gmail.com>
References: <a63d67fe0903240529v6a0e6b51pf67f8ad6dd6842c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, eteo@redhat.com,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:52849 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZC1STB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 14:19:01 -0400
In-Reply-To: <a63d67fe0903240529v6a0e6b51pf67f8ad6dd6842c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter pisze:
> I added a check to smatch (http://repo.or.cz/w/smatch.git/) to check
> for when we dereference
> freed memory.
> 
> (...)
> net/netfilter/nfnetlink_log.c +341 __nfulnl_flush(5) 'inst'
> (...)

I think it's a false positive. In __nfulnl_flush we expect that caller
already holds a reference to inst and it looks like all callers do it.


Marcin
