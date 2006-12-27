From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 01:28:29 +0100
Message-ID: <1167179309.3281.3342.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48322 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932857AbWL0A2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 19:28:33 -0500
To: hadi@cyberus.ca
In-Reply-To: <1167173199.3746.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-26 at 17:46 -0500, jamal wrote:
> On Tue, 2006-26-12 at 23:06 +0100, Arjan van de Ven wrote:
> 
> > it is; that's why irqbalance tries really hard (with a few very rare
> > exceptions) to keep networking irqs to the same cpu all the time...
> > 
> 
> The problem with irqbalance when i last used it is it doesnt take into
> consideration CPU utilization. 

then you used an old ancient version....

> With NAPI, if i have a few interupts it likely implies i have a huge
> network load (and therefore CPU use) and would be much more happier if
> you didnt start moving more interupt load to that already loaded CPU....

current irqbalance accounts for napi by using the number of packets as
indicator for load, not the number of interrupts. (for network
interrupts obviously)


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

