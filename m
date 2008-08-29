From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC] export irq_set/get_affinity() for multiqueue network
 drivers
Date: Fri, 29 Aug 2008 05:50:23 -0700
Message-ID: <20080829055023.07966b4a@infradead.org>
References: <48B708E1.4070001@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35172 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbYH2Owj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 10:52:39 -0400
In-Reply-To: <48B708E1.4070001@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Aug 2008 22:21:53 +0200
Brice Goglin <Brice.Goglin@inria.fr> wrote:

> Hello,
> 
> Is there any way to setup IRQ masks from within a driver? myri10ge
> currently relies on an external script (writing in
> /proc/irq/*/smp_affinity) to bind each queue/MSI-X to a different
> processor. By default, Linux will either:
> * round-robin the interrupts (killing the benefit of DCA for instance)
> * put all IRQs on the same CPU (killing much of th

* do the right thing with the userspace irq balancer

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
