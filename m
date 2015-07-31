From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH][v2] net: phy: add driver for aquantia phy
Date: Fri, 31 Jul 2015 02:01:38 +0000
Message-ID: <BN3PR03MB147973BDA193ABB4BBB6C9DDE28A0@BN3PR03MB1479.namprd03.prod.outlook.com>
References: <1438229835-44865-1-git-send-email-shh.xie@gmail.com>
 <20150730.155501.1888422787034100150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0128.outbound.protection.outlook.com ([207.46.100.128]:14784
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750762AbbGaCBl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 22:01:41 -0400
In-Reply-To: <20150730.155501.1888422787034100150.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, July 31, 2015 6:55 AM
> To: shh.xie@gmail.com
> Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Xie Shaohui-B21989
> Subject: Re: [PATCH][v2] net: phy: add driver for aquantia phy
> 
> From: <shh.xie@gmail.com>
> Date: Thu, 30 Jul 2015 12:17:15 +0800
> 
> > +static int aquantia_soft_reset(struct phy_device *phydev) {
> > +	return 0;
> > +}
> > +
> > +static int aquantia_config_init(struct phy_device *phydev) {
> > +	return 0;
> > +}
> 
> You shouldn't need to implement these methods at all, just leave them
> NULL in the driver struct.
> 
> The only thing implementing them as nop routines like this does is make
> the PHY fixups get scanned.  And I don't think there are any for this
> device.
[S.H] OK. Will remove the nop routines in next version.
Thanks!

Shaohui
