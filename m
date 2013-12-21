From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next v3 06/16] i40e: Implementation of vxlan ndo's
Date: Fri, 20 Dec 2013 18:14:46 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1312201814240.7372@intel.com>
References: <CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com> <20131220.164915.1182500137355120095.davem@davemloft.net> <alpine.LFD.2.03.1312201504460.25549@intel.com> <20131220.204105.425672139698438176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	"or.gerlitz@gmail.com" <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26872 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab3LUB5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 20:57:03 -0500
In-Reply-To: <20131220.204105.425672139698438176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 20 Dec 2013, David Miller wrote:

> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Date: Fri, 20 Dec 2013 15:25:44 -0800 (PST)
> 
> > Right now the code in vxlan.h is:
> > 
> > #if IS_ENABLED(CONFIG_VXLAN)
> > void vxlan_get_rx_port(struct net_device *netdev);
> > #else
> > static inline void vxlan_get_rx_port(struct net_device *netdev)
> > {
> > }
> > #endif
> > 
> > so the function can be called from drivers whether vxlan is enabled in 
> > .config or not. However, the "depends on VXLAN || !VXLAN" is needed when 
> > the driver is compiled as a built-in, otherwise we get an undefined 
> > reference for the above function. If this is not the right way to fix the 
> > dependency please let me know and I will fix it accordingly.
> 
> Ok, can you write this with the more canonical:
> 
> 	(X || X=n)
> 
> That's how we write it out to handle the same issue with
> IPV6.
> 
> Thanks.

Will do. Thanks.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
