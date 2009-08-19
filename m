From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] net: add Xilinx emac lite device driver
Date: Wed, 19 Aug 2009 01:13:16 -0600
Message-ID: <20090819071836.796AD185004B@mail145-dub.bigfish.com>
References: <20090818153047.48E42ED8051@mail66-dub.bigfish.com> <20090818.232815.73515404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jgarzik@pobox.com>, <grant.likely@secretlab.ca>,
	<jwboyer@linux.vnet.ibm.com>, <john.williams@petalogix.com>,
	<michal.simek@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:25838 "EHLO
	IE1EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbZHSHSh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 03:18:37 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20090818.232815.73515404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David, I may have got over zealous in my clean up to get it ready
for mainline.

I'll take care of that.

-- John

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 19, 2009 7:28 AM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
jgarzik@pobox.com; grant.likely@secretlab.ca;
> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com;
michal.simek@petalogix.com; Sadanand Mutyala
> Subject: Re: [PATCH] net: add Xilinx emac lite device driver
> 
> From: John Linn <john.linn@xilinx.com>
> Date: Tue, 18 Aug 2009 09:30:41 -0600
> 
> > @@ -1926,6 +1926,11 @@ config ATL2
> >  	  To compile this driver as a module, choose M here.  The module
> >  	  will be called atl2.
> >
> > +config XILINX_EMACLITE
> > +	tristate "Xilinx 10/100 Ethernet Lite support"
> > +	help
> > +	  This driver supports the 10/100 Ethernet Lite from Xilinx.
> > +
> >  source "drivers/net/fs_enet/Kconfig"
> >
> >  endif # NET_ETHERNET
> 
> You can't unconditionally enable this driver everywhere.
> It depends upon things like openfirmware support, etc.
> so the driver will fail to link if the architecture doesn't
> have those support routines.
> 
> Please fix this up, thanks.


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


