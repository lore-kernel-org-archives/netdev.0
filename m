From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: add tx checksum offload support
Date: Thu, 20 Nov 2008 00:54:14 -0800 (PST)
Message-ID: <20081120.005414.123636787.davem@davemloft.net>
References: <20081119.142855.124711576.davem@davemloft.net>
	<OF79130DF4.191FC25A-ON80257507.002E9C9F-80257507.00309F9A@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.saturley@smsc.com, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45912
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbYKTIyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:54:15 -0500
In-Reply-To: <OF79130DF4.191FC25A-ON80257507.002E9C9F-80257507.00309F9A@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Thu, 20 Nov 2008 08:50:16 +0000

> Hi David,
> 
> David Miller <davem@davemloft.net> wrote on 19/11/2008 22:28:55:
> 
> > From: Steve Glendinning <steve.glendinning@smsc.com>
> > Date: Mon, 17 Nov 2008 10:50:00 +0000
> > 
> > > @@ -757,6 +787,7 @@ static int smsc95xx_phy_initialize(struct usbnet 
> *dev)
> > >  static int smsc95xx_reset(struct usbnet *dev)
> > >  {
> > >     struct smsc95xx_priv *pdata = (struct smsc95xx_priv 
> *)(dev->data[0]);
> > > +   struct net_device *netdev = dev->net;
> > >     u32 read_buf, write_buf, burst_cap;
> > >     int ret = 0, timeout;
> > >     DECLARE_MAC_BUF(mac);
> > 
> > This smsc95xx_reset function doesn't even exist in the current driver.
> 
> Are you sure you're looking at the same drivers/net/usb/smsc95xx.c?  In 
> both Linus's tree and net-next-2.6 this function is on line 757.

I think I was looking at drivers/net/smsc*.c :-)  Silly me.

> The patch was against Linus's tree, the version in net-next-2.6 also has 
> Johannes Berg's print_mac patch applied so this section of code no longer 
> has DECLARE_MAC_BUF(mac);.  Would you like me to rebase against 
> net-next-2.6 and resubmit?

Yes, please do, that's where I was going to apply it anyways.

Thanks!
