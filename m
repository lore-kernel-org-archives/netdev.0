From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 02 Jan 2007 09:57:56 -0800
Message-ID: <459A9D24.8000807@hp.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>	<1167039303.3281.1574.camel@laptopd505.fenrus.org>	<7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>	<1167046499.3281.1623.camel@laptopd505.fenrus.org>	<7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>	<1167158658.3746.12.camel@localhost>	<1167170793.3281.3209.camel@laptopd505.fenrus.org>	<1167173199.3746.45.camel@localhost> <1167179309.3281.3342.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Robert Iakobashvili <coroberti@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56594 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932695AbXABR55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 12:57:57 -0500
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1167179309.3281.3342.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>With NAPI, if i have a few interupts it likely implies i have a huge
>>network load (and therefore CPU use) and would be much more happier if
>>you didnt start moving more interupt load to that already loaded CPU....
> 
> 
> current irqbalance accounts for napi by using the number of packets as
> indicator for load, not the number of interrupts. (for network
> interrupts obviously)

And hopefully some knowledge of NUMA so it doesn't "balance" the 
interrupts of a NIC to some far-off (topology-wise) CPU...

rick jones
