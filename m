From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Fri, 2 May 2008 23:16:36 -0700
Message-ID: <20080502231636.55a6b86a@speedy>
References: <20080501145239.GA20284@atlantis.mitranet.cz>
	<20080502.172600.45356095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yanek@ya.bofh.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56977 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265AbYECGQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 May 2008 02:16:41 -0400
In-Reply-To: <20080502.172600.45356095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 May 2008 17:26:00 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
> Date: Thu, 1 May 2008 17:49:14 +0200
> 
> > I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:
> 
> Thanks for this report, I'll try to figure it out.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This problem isn't new (I think it is even buried in kernel bugzilla).
