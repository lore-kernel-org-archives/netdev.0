From: Tino Reichardt <list-linux-netdev@mcmilk.de>
Subject: Re: [PATCH 01/07] 8139too: Support for byte queue limits
Date: Mon, 14 Oct 2013 21:52:01 +0200
Message-ID: <20131014195201.GD23070@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
 <1381775183-24866-2-git-send-email-milky-kernel@mcmilk.de>
 <1381777891.2045.1.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:39547 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab3JNTwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 15:52:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by lotte.svc-box.de (Postfix) with ESMTP id 73993148018F
	for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 21:52:03 +0200 (CEST)
Received: from lotte.svc-box.de ([127.0.0.1])
	by localhost (lotte.svc-box.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id gwAOlWdgcVjO for <netdev@vger.kernel.org>;
	Mon, 14 Oct 2013 21:52:01 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1381777891.2045.1.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-10-14 at 20:26 +0200, Tino Reichardt wrote:
> > Changes to 8139too to use byte queue limits.
> > 
> > @@ -1733,6 +1735,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
> >  		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
> >  
> >  	tp->cur_tx++;
> > +	netdev_sent_queue(dev, len);
> >  
> 
> This looks wrong if len < ETH_ZLEN

Fixed this (really stupid) issue, updated patch is located here:
 http://www.mcmilk.de/projects/linux-bql/dl/0001-8139too-Support-for-byte-queue-limits.patch


The netif_dbg() statement will now also print the correct queued length.

-- 
Best regards, TR
