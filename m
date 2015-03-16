From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [linuxppc-release] [PATCH] net/fsl: modify xgmac_mdio for little
 endian SoCs
Date: Mon, 16 Mar 2015 07:11:08 +0000
Message-ID: <CY1PR03MB1486DA44A9C9A835A0FDAE92E2020@CY1PR03MB1486.namprd03.prod.outlook.com>
References: <1426483371-3286-1-git-send-email-shh.xie@gmail.com>
 <55067EA9.7030303@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Emilian Medve <Emilian.Medve@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0147.outbound.protection.outlook.com ([65.55.169.147]:57760
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750736AbbCPHnj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 03:43:39 -0400
In-Reply-To: <55067EA9.7030303@Freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 03/16/2015 12:22 AM, shh.xie@gmail.com wrote:
> > From: Shaohui Xie <Shaohui.Xie@freescale.com>
> >
> > MDIO controller on little endian Socs, e.g. ls2085a is similar to the
> > controller on big endian Socs, but the MDIO access is little endian,
> > we use I/O accessor function to handle endianness, so the driver can
> > run on little endian Socs. A property "fsl,little-endian-mdio" is used
> > in DTS to indicate the MDIO is little endian, if driver probes the
> > property, driver will access MDIO in little endian.
> 
> Please use "{big,little}-endian" with "big-endian" being the default if
> none is present. Please look at
> Documentation/devicetree/bindings/regmap/regmap.txt and more then a dozen
> FSL bindings already using this
[S.H] OK. I'll align driver with the Doc.

> 
> > Also, fix a bug in xgmac_wait_until_done() which mdio_stat should be
> > used instead of mdio_data when checking if busy bit is cleared.
> 
> Please split this into a separate patch
[S.H] OK. 

Thank you!
Shaohui
