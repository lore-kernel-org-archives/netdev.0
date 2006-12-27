From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 22:47:59 -0500
Message-ID: <1167191279.3746.60.camel@localhost>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
	 <1167179309.3281.3342.camel@laptopd505.fenrus.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:10696 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932897AbWL0DsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 22:48:02 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4074330wxd
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 19:48:02 -0800 (PST)
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1167179309.3281.3342.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-27-12 at 01:28 +0100, Arjan van de Ven wrote:

> current irqbalance accounts for napi by using the number of packets as
> indicator for load, not the number of interrupts. (for network
> interrupts obviously)
> 

Sounds a lot more promising.
Although still insufficient in certain cases. All flows are not equal; as an
example, an IPSEC flow with 1000 packets bound to one CPU  will likely
utilize more cycles than 5000 packets that are being plain forwarded on
another CPU.

cheers,
jamal

