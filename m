From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 14:08:08 +0100
Message-ID: <1167224888.3281.3876.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
	 <1167179309.3281.3342.camel@laptopd505.fenrus.org>
	 <1167191279.3746.60.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46007 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932791AbWL0NIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 08:08:12 -0500
To: hadi@cyberus.ca
In-Reply-To: <1167191279.3746.60.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Although still insufficient in certain cases. All flows are not equal; as an
> example, an IPSEC flow with 1000 packets bound to one CPU  will likely
> utilize more cycles than 5000 packets that are being plain forwarded on
> another CPU.

sure; however the kernel doesn't provide more accurate information
currently (and I doubt it could even, it's not so easy to figure out
which interface triggered the softirq if 2 interfaces share the cpu, and
then, how much work came from which etc).

also the "amount of work" estimate doesn't need to be accurate to 5
digits to be honest... just number of packets seems to be a quite
reasonable approximation already. (if the kernel starts exporting more
accurate data, irqbalance can easily use it of course)
-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

