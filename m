From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [RFC 1/2] net: Add support to configure SR-IOV VF minimum and
 maximum Tx rate through ip tool.
Date: Wed, 5 Mar 2014 09:36:26 +0000
Message-ID: <290BEC245535C3449143D5D84900EEF78CDFAB7A@avmb3.qlogic.org>
References: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
 <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
 <20140305093312.GA27992@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:16337 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574AbaCEJgb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 04:36:31 -0500
In-Reply-To: <20140305093312.GA27992@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Kubecek [mailto:mkubecek@suse.cz]
> Sent: Wednesday, March 05, 2014 3:03 PM
> To: Sucheta Chakraborty
> Cc: David Miller; netdev; Dept-HSG Linux NIC Dev
> Subject: Re: [RFC 1/2] net: Add support to configure SR-IOV VF minimum
> and maximum Tx rate through ip tool.
> 
> On Wed, Mar 05, 2014 at 02:33:35AM -0500, Sucheta Chakraborty wrote:
> > diff --git a/include/uapi/linux/if_link.h
> > b/include/uapi/linux/if_link.h index 16410b6..fce6437 100644
> > --- a/include/uapi/linux/if_link.h
> > +++ b/include/uapi/linux/if_link.h
> > @@ -398,7 +398,8 @@ enum {
> >  	IFLA_VF_UNSPEC,
> >  	IFLA_VF_MAC,		/* Hardware queue specific attributes */
> >  	IFLA_VF_VLAN,
> > -	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> > +	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
> > +	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
> >  	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
> >  	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch
> */
> >  	__IFLA_VF_MAX,
> 
> This would change the values of IFLA_VF_SPOOFCHK and
> IFLA_VF_LINK_STATE, making "old" (including current) iproute2
> incompatible with future kernels and vice versa.
> 
>                                                          Michal Kubecek

Thanks Michal for pointing this out. I will move the new enum "IFLA_VF_RATE" to the end of the list.

- Sucheta.
