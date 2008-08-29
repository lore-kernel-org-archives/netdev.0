From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [RFC] export irq_set/get_affinity() for multiqueue network drivers
Date: Fri, 29 Aug 2008 09:08:41 +0200
Message-ID: <48B7A079.5070409@inria.fr>
References: <48B708E1.4070001@inria.fr> <20080828.135609.106382483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:58447 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbYH2HII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:08:08 -0400
In-Reply-To: <20080828.135609.106382483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I think we should rather have some kind of generic thing in the
> IRQ layer that allows specifying the usage model of the device's
> interrupts, so that the IRQ layer can choose a default affinities.
> 
> I never notice any of this complete insanity on sparc64 because
> we flat spread out all of the interrupts across the machine.
> 
> What we don't want it drivers choosing IRQ affinity settings,
> they have no idea about NUMA topology, what NUMA node the
> PCI controller sits behind, what cpus are there, etc.  and
> without that kind of knowledge you cannot possible make
> affinity decisions properly.

As long as we get something better than the current behavior, I am fine
with it :)

Brice
