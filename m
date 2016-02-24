From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: RE: [PATCH 2/3] gianfar_ptp: fix endianness in get_of_u32()
Date: Wed, 24 Feb 2016 09:23:10 +0000
Message-ID: <HE1PR04MB088910A68538A88B66ABCC13F8A50@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <1456123773-1016-3-git-send-email-yangbo.lu@nxp.com>
 <20160222083558.GB2138@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0058.outbound.protection.outlook.com ([157.56.112.58]:25568
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752988AbcBXK5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 05:57:18 -0500
In-Reply-To: <20160222083558.GB2138@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, February 22, 2016 4:36 PM
> To: Yangbo Lu
> Cc: netdev@vger.kernel.org; Claudiu Manoil
> Subject: Re: [PATCH 2/3] gianfar_ptp: fix endianness in get_of_u32()
> 
> On Mon, Feb 22, 2016 at 02:49:32PM +0800, Yangbo Lu wrote:
> > @@ -431,7 +431,7 @@ static int get_of_u32(struct device_node *node,
> > char *str, u32 *val)
> >
> >  	if (!prop || plen != sizeof(*prop))
> >  		return -1;
> > -	*val = *prop;
> > +	*val = be32_to_cpu(*prop);
> >  	return 0;
> >  }
> 
> Why not simply replace get_of_u32 with the standard helper function,
> of_property_read_u32?

[Lu Yangbo-B47093] Thank you for your suggestion. I even didn't know this function.
Will use it in v2 patchset.

> 
> Thanks,
> Richard
