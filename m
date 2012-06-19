From: <Parav.Pandit@Emulex.Com>
Subject: RE: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 05:20:52 +0000
Message-ID: <5D6C0ABE6A236946864C45679362BBE20AC52202@CMEXMB1.ad.emulex.com>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
 <4FDF56FB.9080509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>
To: <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:13369 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753300Ab2FSFVO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 01:21:14 -0400
In-Reply-To: <4FDF56FB.9080509@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Rick Jones [mailto:rick.jones2@hp.com]
> Sent: Monday, June 18, 2012 9:58 PM
> To: Pandit, Parav
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
> Subject: Re: [PATCH] net: added support for 40GbE link.
> 
> On 06/18/2012 05:44 AM, Parav Pandit wrote:
> 
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h index
> > 297370a..1ebfa6e 100644
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
> 
100G supports CR10, ER4, LR4, Base-R and SR10 interfaces. So 5 bits. We have space from 27 to 31 bits for 100G as well.

> rick jones
