From: Ben Boeckel <mathstuf@gmail.com>
Subject: Re: [PATCH net-next 1/6] epic100: replace printk with netdev_ calls
Date: Fri, 1 Nov 2013 00:31:58 -0400
Message-ID: <20131101043158.GA13804@bronto-burt.dev.benboeckel.net>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1382682422-22677-2-git-send-email-mathstuf@gmail.com>
 <1382683266.2068.13.camel@joe-AO722>
Reply-To: mathstuf@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:37261 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab3KAEcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:32:02 -0400
Received: by mail-qe0-f51.google.com with SMTP id q19so2331739qeb.38
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:32:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1382683266.2068.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 23:41:06 -0700, Joe Perches wrote:
> On Fri, 2013-10-25 at 02:26 -0400, Ben Boeckel wrote:
> Please run your patches through checkpatch.pl

Done. There are some 80 character limit issues yet, but they're literal
strings for the most part. I also left rampant space-for-indent as-is
(though I did nab a few space-between-tab instances I spotted).

> > diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
> []
> > @@ -490,7 +488,7 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  	if (ret < 0)
> >  		goto err_out_unmap_rx;
> >  
> > -	printk(KERN_INFO "%s: %s at %lx, IRQ %d, %pM\n",
> > +	netdev_info(dev, "%s: %s at %lx, IRQ %d, %pM\n",
> >  	       dev->name, pci_id_tbl[chip_idx].name,
> >  	       (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
> >  	       dev->dev_addr);
> 
> Please align the subsequent lines to the open parenthesis
> and this conversion would now emit dev->name twice.

Done.

> Please coalesce the format fragments into a single line.
> 
> >  					   dev->name, mdio_read(dev, ep->phys[0], MII_BMSR));
> 
> same problem with duplicate dev->name

Done.

--Ben
