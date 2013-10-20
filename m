From: Tino Reichardt <list-linux-netdev@mcmilk.de>
Subject: Re: [PATCH net-next v2 01/07] 8139too: Support for byte queue limits
Date: Sun, 20 Oct 2013 21:14:11 +0200
Message-ID: <20131020191411.GA24935@mcmilk.de>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
 <1382292803-18875-2-git-send-email-milky-kernel@mcmilk.de>
 <1382295089.2041.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:49155 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab3JTTOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 15:14:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by lotte.svc-box.de (Postfix) with ESMTP id 74BC41480B81
	for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 21:14:12 +0200 (CEST)
Received: from lotte.svc-box.de ([127.0.0.1])
	by localhost (lotte.svc-box.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id SulJLvSba4BN for <netdev@vger.kernel.org>;
	Sun, 20 Oct 2013 21:14:11 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1382295089.2041.42.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Joe Perches <joe@perches.com> wrote:
> On Sun, 2013-10-20 at 20:13 +0200, Tino Reichardt wrote:
> > Changes to 8139too driver to use byte queue limits.
> []
> > diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
> []
> > @@ -1409,6 +1413,8 @@ static void rtl8139_hw_start (struct net_device *dev)
> []
> >  	netdev_dbg(dev, "init buffer addresses\n");
> > +	if (likely(bql_disable == false))
> > +		netdev_reset_queue(dev);
> 
> Much prefer:
> 
> 	if (unlikely(bql_disable))

Okay, i will resend an updated v3 patchset.



-- 
Best regards, TR
