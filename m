From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 15:00:35 -0700 (PDT)
Message-ID: <20070612.150035.60555425.davem@davemloft.net>
References: <20070612.142658.45082832.davem@davemloft.net>
	<466F142C.4040109@garzik.org>
	<adazm347sdw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, greearb@candelatech.com, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbXFLWAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 18:00:19 -0400
In-Reply-To: <adazm347sdw.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 12 Jun 2007 14:52:11 -0700

> I think you're misunderstanding.  These NICs still have only one
> physical port, so sending or receiving real packets onto a physical
> wire is fundamentally serialized.  The steering of packets to receive
> queues is done right after the packets are received from the wire --
> in fact it can be done as soon as the NIC has parsed enough of the
> headers to make a decision, which might be before the full packet has
> even been received.  The steering is no more of a bottleneck than the
> physical link is.

Yep, that's right.
