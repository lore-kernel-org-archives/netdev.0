From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:58:54 -0700 (PDT)
Message-ID: <20070606.165854.26276338.davem@davemloft.net>
References: <20070606.153530.48530367.davem@davemloft.net>
	<1181172766.4064.83.camel@localhost>
	<466747EB.5020101@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756331AbXFFX6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:58:38 -0400
In-Reply-To: <466747EB.5020101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 06 Jun 2007 16:48:59 -0700

>   > RX queues - yes, I can see;  TX queues, it doesnt make sense to put
> > different rings on different CPUs.
> 
> To what extent might that preclude some cachelines bouncing hither and 
> yon between the CPUs?

I think per-TX-queue locking takes locality as another advantage.
You only touch the TX descriptors for queue N, rather than a single
globally shared one.

Same goes for RX.
