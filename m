From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: 3c59x: shared interrupt problem
Date: Thu, 12 Mar 2009 15:39:30 +0100
Message-ID: <20090312143930.GA17955@newton.mathematik.tu-chemnitz.de>
References: <20090311224240.63430@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Gerhard Pircher <gerhard_pircher@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:52756 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbZCLOjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:39:35 -0400
Content-Disposition: inline
In-Reply-To: <20090311224240.63430@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 11:42:40PM +0100, Gerhard Pircher wrote:
> 
> > Your first report showed dnComplete as a pending interrupt source.
> > Since the driver uses tx_interrupt_mitigation, this happens just if the 
> > tx ring is full. Could you please test the patch below? This disables
> > tx_interrupt_mitigation, so the dnComplete interrupt will be triggered 
> > with every packet.
> I disabled tx_interrupt_mitigation and tested it with and w/o the patch
> for boomerang_interrupt(). The network transfer stalls in both cases
> sooner or later.
> 
> Here are two photos from the kernel output:
> - no tx_interrupt_mitigation and patch for booomerang_interrupt():
> http://boot.homelinux.org:8080/kernel/oops_boomerang_irq_tx_irq_mitig.jpg
> - no tx_interrupt_mitigation only:
> http://boot.homelinux.org:8080/kernel/oops_tx_irq_mitig.jpg
> 

Your pictures show just a message at shutdown. Are there any other unusual
messages from the 3c59x driver in your logs? In particular I'm interested in 
"transmit timed out" messages.
