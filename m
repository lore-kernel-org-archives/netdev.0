From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 13:41:37 +0200
Message-ID: <20090417134137.77b5dbd7@hskinnemoen-d830>
References: <20090417112553.21e1f2e5@hskinnemoen-d830>
	<20090417.023357.121366056.davem@davemloft.net>
	<20090417115011.5c3d17e1@hskinnemoen-d830>
	<20090417.034416.110856368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:60438 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756349AbZDQLlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 07:41:49 -0400
In-Reply-To: <20090417.034416.110856368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
> Date: Fri, 17 Apr 2009 11:50:11 +0200
> 
> > No, therefore, I'd prefer local_irq_save() :-)
> 
> I'm pretty sure there is a specific reason driver's use
> disable_irq() rather than disabling local cpu IRQs.

Looks like most if not all of the ARM drivers use local_irq_save()...I
couldn't figure out what etherh does from a quick scan.

> I just can't remember it at the moment.
> 
> And there absolutely must be a reason, because disable_irq()
> is a lot more expensive.

Sounds like another reason _not_ to use it ;-)

Well, if you're really sure about this, I guess you might as well go
ahead and apply it. But it feels wrong to Ack the patch when I don't
know the reason for using disable_irq() and can think of several
reasons _not_ to use it...

Haavard
