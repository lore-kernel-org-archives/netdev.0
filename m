From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Mon, 25 Jun 2007 09:25:35 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179814@orsmsx414.amr.corp.intel.com>
References: <467E5CC4.8070503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18786 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbXFYQZj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 12:25:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467E5CC4.8070503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  	/* ensure 32-byte alignment of both the device and 
> private area */
> > -	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & 
> ~NETDEV_ALIGN_CONST;
> > +	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
> > +		     (sizeof(struct net_device_subqueue) * 
> (queue_count - 1))) &
> 
> 
> Why queue_count - 1 ? It should be queue_count I think.

I'm not sure what went through my head, but I'll fix this.

> Otherwise ACK for this patch except that it should also 
> contain the sch_generic changes.

I misread your previous mail; I'll get the sch_generic.c changes into
this patch.

Thanks Patrick,
-PJ
