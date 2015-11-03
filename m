From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH][v2] net: phy: fix a bug in get_phy_c45_ids
Date: Tue, 3 Nov 2015 04:33:09 +0000
Message-ID: <BLUPR03MB1475BC9C57155AD0FE6E47F1E22B0@BLUPR03MB1475.namprd03.prod.outlook.com>
References: <1446461313-37628-1-git-send-email-shh.xie@gmail.com>
 <20151102.230203.435663540046979084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0143.outbound.protection.outlook.com ([157.56.110.143]:6428
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750774AbbKCFGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 00:06:41 -0500
In-Reply-To: <20151102.230203.435663540046979084.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, November 03, 2015 12:02 PM
> To: shh.xie@gmail.com
> Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Xie Shaohui-B21989
> Subject: Re: [PATCH][v2] net: phy: fix a bug in get_phy_c45_ids
> 
> From: <shh.xie@gmail.com>
> Date: Mon, 2 Nov 2015 18:48:33 +0800
> 
> > @@ -205,6 +205,37 @@ struct phy_device *phy_device_create(struct
> > mii_bus *bus, int addr, int phy_id,  }
> > EXPORT_SYMBOL(phy_device_create);
> >
> > + /* get_phy_c45_devs_in_pkg - reads a MMD's devices in package
> registers.
> > + * @bus: the target MII bus
> 
> Please remove the leading space on the first line of this new comment.
OK. Fixed in V3.

Thank you!

--Shaohui
