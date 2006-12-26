From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 23:06:33 +0100
Message-ID: <1167170793.3281.3209.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40156 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932787AbWLZWGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 17:06:38 -0500
To: hadi@cyberus.ca
In-Reply-To: <1167158658.3746.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-26 at 13:44 -0500, jamal wrote:
> If you compile in PCI-E support you should have more control of the
> MSI-X, no? I would tie the MSI to a specific processor statically; my
> past experiences with any form of interupt balancing with network loads
> has been horrible.


it is; that's why irqbalance tries really hard (with a few very rare
exceptions) to keep networking irqs to the same cpu all the time...

but if your use case is kernel level packet processing of < MTU packets
then I can see why you would at some point would run out of cpu
power ... esp on multicore where you share the cache between cores you
probably can do a little better for that very specific use case.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

