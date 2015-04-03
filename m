From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: Re: [PATCH RFC 06/10] dpaa_eth: add ethtool functionality
Date: Fri, 3 Apr 2015 08:54:36 +0000
Message-ID: <BL2PR03MB54597F6E69800CDAE4D31D0E6F10@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0126.outbound.protection.outlook.com ([65.55.169.126]:7982
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752353AbbDCIyj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 04:54:39 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> > Add support for basic ethtool operations.
> 
> > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
> b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
> []
> > +static int __cold dpa_get_settings(struct net_device *net_dev,
> > +				   struct ethtool_cmd *et_cmd)
> > +{
> > +	int			 _errno;
> 
> Using a variable name of _errno is misleading at best,
> (btw: the only return value for phy_ethtool_gset is 0)

I'll rename all miss-used occurrences of _errno.
 
> > +static void __cold dpa_get_drvinfo(struct net_device *net_dev,
> > +				   struct ethtool_drvinfo *drvinfo)
> > +{
> > +	int		 _errno;
> > +
> > +	strncpy(drvinfo->driver, KBUILD_MODNAME,
> > +		sizeof(drvinfo->driver) - 1)[sizeof(drvinfo->driver) - 1] = 0;
> 
> That's a really odd and unusual construct
> more commonly written as strlcpy

I will change this.

> > +	_errno = snprintf(drvinfo->version, sizeof(drvinfo->version),
> 
> Using errno here is especially misleading as that's
> not the return value of an snprintf

I will take care of this one too.

Thank you,
Madalin
