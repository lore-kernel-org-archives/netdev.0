From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP [<ffffffff819109a2>]
 skb_segment+0x6b2/0x6d0
Date: Thu, 21 Nov 2013 10:23:36 -0800
Message-ID: <1385058216.10637.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1287049824.20131117201744@eikelenboom.it>
	 <1392359825.20131121130027@eikelenboom.it>
	 <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131121.131741.737292941735802990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux@eikelenboom.it,
	edumazet@google.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:57682 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab3KUSXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:23:39 -0500
Received: by mail-yh0-f51.google.com with SMTP id t59so6814599yho.10
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 10:23:38 -0800 (PST)
In-Reply-To: <20131121.131741.737292941735802990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 13:17 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 21 Nov 2013 06:10:04 -0800
> 
> > As mentioned earlier, this problem is known and a patch is under review.
> > 
> > http://marc.info/?l=linux-netdev&m=138419594024851&w=2
> 
> It seems this patch still requires some improvements, can you guys sort
> out what needs to be done so that I can apply a fix soon?

I think we might apply this patch as is, and do the TSO optimization
when net-next reopens ?

I was planning to resend Herbert patch today anyway, after a new round
of testing on my hosts.
