From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 18:18:22 -0400
Message-ID: <466F1BAE.9040908@garzik.org>
References: <466F142C.4040109@garzik.org>	<adazm347sdw.fsf@cisco.com>	<466F174F.5090206@garzik.org> <20070612.150450.17595071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, greearb@candelatech.com, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58897 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940AbXFLWS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 18:18:27 -0400
In-Reply-To: <20070612.150450.17595071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> If you're asking about the virtualization scenerio, the
> control node (dom0 or whatever) is the only entity which
> can get at programming the filters and will set it up
> properly based upon which parts of the physical device
> are being exported to which guest nodes.

You're avoiding the question.  Clearly guest VMs must contact the host 
VM (dom0) to get real work done.

They are ultimately going to have to pass the same configuration info as 
the non-virt case.


> For the non-virtualized case, it's a good question.

...



> But really the current hardware is just about simple queue steering,
> and simple static DRR/WRED fairness algorithms applied to the queues
> in hardware.
> 
> We don't need to add support for configuring anything fancy from the
> start just to get something working.

Correct.  But if we don't plan for the future that's currently in the 
silicon pipeline, our ass will be in a sling WHEN we must figure out the 
best configuration points for sub-queues.

Or are we prepared to rip out sub-queues for a non-experimental 
solution, when confronted with the obvious necessity of configuring them?

You know I want multi-queue and increased parallelism it provides.  A lot.

But let's not dig ourselves into a hole we must climb out of in 6-12 
months.  We need to think about configuration issues -now-.

	Jeff



