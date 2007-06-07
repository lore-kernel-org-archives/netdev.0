From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 17:01:44 -0700 (PDT)
Message-ID: <20070606.170144.68041448.davem@davemloft.net>
References: <1181172766.4064.83.camel@localhost>
	<466747EB.5020101@hp.com>
	<1181174087.4064.100.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S936296AbXFGAB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 20:01:28 -0400
In-Reply-To: <1181174087.4064.100.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Jun 2007 19:54:47 -0400

> On Wed, 2007-06-06 at 16:48 -0700, Rick Jones wrote:
> >   > RX queues - yes, I can see;  TX queues, it doesnt make sense to put
> > > different rings on different CPUs.
> > 
> > To what extent might that preclude some cachelines bouncing hither and 
> > yon between the CPUs?
> 
> I think the bouncing will exist a lot more with the multi CPUs. But one
> would assume if you go that path, you would also parallelize the stack
> on egress to reduce such an effect. I guess the point i am not seeing is
> the value. The tx, once hitting the NIC is an IO issue not a CPU issue.

Disagred, that single TX lock kills cpu cycles.

If all of the TX queues are independantly programmable of one
another, the single TX lock kills performance.

> off for the night.

Enjoy the game.
