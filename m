From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSOframe   size
Date: Thu, 28 Feb 2008 09:16:01 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290498D30E@orsmsx414.amr.corp.intel.com>
References: <20080227172606.4446.97153.stgit@localhost.localdomain> <20080228080746.GA7067@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <stephen.hemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255AbYB1RTD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 12:19:03 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080228080746.GA7067@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  	dev->egress_subqueue_count = queue_count;
> > +	dev->max_gso_frame_size = 65536;
> 
> Does it fit into u16?

No it doesn't.  I originally had this as an int, and borked it when
switching it to unsigned.  I'll fix this asap.

> Isn't it "nicer" with some constant (#define MAX_GSO_FRAME_SIZE ...)?

Yes it is.  I'll add this.

> Why not more consistent names, e.g.:
> dev->gso_max_size;
> sk_gso_max_size;
> netif_set_gso_max_size()
> (GSO_MAX_SIZE)
> or
> dev->max_gso_frame_size;
> sk_max_gso_frame_size;
> netif_set_max_gso_frame_size()
> (MAX_GSO_FRAME_SIZE)
> etc.?

Very good point.  I'll change this and resend today.  Thanks a bunch for
the feedback!

Cheers,

-PJ Waskiewicz
