From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Mon, 21 May 2012 14:42:13 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F13@saturn3.aculab.com>
References: <20120520164114.GD21177@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Alan Cox" <alan@linux.intel.com>
To: "Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"Ondrej Zary" <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47405 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755863Ab2EUNmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 09:42:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02539-09 for <netdev@vger.kernel.org>;
 Mon, 21 May 2012 14:42:50 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120520164114.GD21177@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Regardless, to answer your questions:
> 
> 1) No, obviously an rm-rf of all drivers that can't probe quietly was 
> not going to happen; that was never implicilty or explicitly proposed.
> 
> 2) From memory while working on the 3c503 driver 15 odd years ago, it
> could probe silently and semi reliably, which was impressive 
> then, given it was pre ISA-PnP.  It was worlds ahead of a 3c501 card.

Probing for non-pnp ISA cards is definitely unreliable.
Maybe some of these drivers should need to be explicitly
enabled in the kernel config.
That should let people with the cards use them, without
the danger of unexpected error messages and possible
system lockups!

ISTR that the Olicom ISA-pnp token ring card would lock
the bus solid if hit by the probe for the non-pnp variant!
(or maybe it was the other way around).

I hadn't realised how bad some of the 3cxxx cards were!
I thought the 'parallel tasking' was all about starting
to tx a frame while the host was still copting it to the
tx fifo (and rx copies before end of frame), not that
it couldn't receive while the host was reading out a
packet. I was writing drivers for the amd lance at
much the same time...
(Mind you, the intel device of that era was somewhat
difficult to use as well.)

	David
