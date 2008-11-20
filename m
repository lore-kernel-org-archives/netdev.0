From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc95xx: add tx checksum offload support
Date: Thu, 20 Nov 2008 08:50:16 +0000
Message-ID: <OF79130DF4.191FC25A-ON80257507.002E9C9F-80257507.00309F9A@smsc.com>
References: <20081119.142855.124711576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ian.saturley@smsc.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1742 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753988AbYKTIvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 03:51:39 -0500
In-Reply-To: <20081119.142855.124711576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> wrote on 19/11/2008 22:28:55:

> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Mon, 17 Nov 2008 10:50:00 +0000
> 
> > @@ -757,6 +787,7 @@ static int smsc95xx_phy_initialize(struct usbnet 
*dev)
> >  static int smsc95xx_reset(struct usbnet *dev)
> >  {
> >     struct smsc95xx_priv *pdata = (struct smsc95xx_priv 
*)(dev->data[0]);
> > +   struct net_device *netdev = dev->net;
> >     u32 read_buf, write_buf, burst_cap;
> >     int ret = 0, timeout;
> >     DECLARE_MAC_BUF(mac);
> 
> This smsc95xx_reset function doesn't even exist in the current driver.

Are you sure you're looking at the same drivers/net/usb/smsc95xx.c?  In 
both Linus's tree and net-next-2.6 this function is on line 757.

The patch was against Linus's tree, the version in net-next-2.6 also has 
Johannes Berg's print_mac patch applied so this section of code no longer 
has DECLARE_MAC_BUF(mac);.  Would you like me to rebase against 
net-next-2.6 and resubmit?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
