From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: added support for 40GbE link.
Date: Mon, 18 Jun 2012 17:56:32 +0100
Message-ID: <1340038592.2913.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
	 <4FDF56FB.9080509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Parav Pandit <parav.pandit@emulex.com>, <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55085 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750792Ab2FRQ4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 12:56:38 -0400
In-Reply-To: <4FDF56FB.9080509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 09:27 -0700, Rick Jones wrote:
> On 06/18/2012 05:44 AM, Parav Pandit wrote:
> 
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > index 297370a..1ebfa6e 100644
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -1153,6 +1153,10 @@ struct ethtool_ops {
> >   #define SUPPORTED_10000baseR_FEC	(1<<  20)
> >   #define SUPPORTED_20000baseMLD2_Full	(1<<  21)
> >   #define SUPPORTED_20000baseKR2_Full	(1<<  22)
> > +#define SUPPORTED_40000baseKR4_Full	(1<<  23)
> > +#define SUPPORTED_40000baseCR4_Full	(1<<  24)
> > +#define SUPPORTED_40000baseSR4_Full	(1<<  25)
> > +#define SUPPORTED_40000baseLR4_Full	(1<<  26)
> >
> >   /* Indicates what features are advertised by the interface. */
> >   #define ADVERTISED_10baseT_Half		(1<<  0)
> > @@ -1178,6 +1182,10 @@ struct ethtool_ops {
> >   #define ADVERTISED_10000baseR_FEC	(1<<  20)
> >   #define ADVERTISED_20000baseMLD2_Full	(1<<  21)
> >   #define ADVERTISED_20000baseKR2_Full	(1<<  22)
> > +#define ADVERTISED_40000baseKR4_Full	(1<<  23)
> > +#define ADVERTISED_40000baseCR4_Full	(1<<  24)
> > +#define ADVERTISED_40000baseSR4_Full	(1<<  25)
> > +#define ADVERTISED_40000baseLR4_Full	(1<<  26)
> 
> Any idea how many defines will be wanted for 100 Gbit Ethernet? 
> Supported and advertising in ethtool_cmd are __u32s...

There are 9 bytes reserved in struct ethtool_cmd, so we can potentially
add extend each of supported, advertising and lp_advertising by 24 bits.
But it might be better to define a new, cleaner struct ethtool_cmd.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
