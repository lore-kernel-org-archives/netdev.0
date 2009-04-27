From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: irq_of_parse_and_map() error unnoticed
Date: Mon, 27 Apr 2009 03:11:16 -0700 (PDT)
Message-ID: <20090427.031116.43598009.davem@davemloft.net>
References: <49F0649C.8030908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33166
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752476AbZD0KLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:11:23 -0400
In-Reply-To: <49F0649C.8030908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 23 Apr 2009 14:52:44 +0200

> Not sure which irq_of_parse_and_map() is used, but I found definitions here:
> 
> vi arch/microblaze/kernel/irq.c +23
> vi arch/powerpc/kernel/irq.c +727
> vi arch/sparc/kernel/of_device_32.c +33
> vi arch/sparc/kernel/of_device_64.c +59
> 
> They either return 0 or NO_IRQ - either defined 0, -1, 255 or INT_MAX.
> ------------------------------>8-------------8<---------------------------------
> priv->interruptTransmit, -Receive and -Error are unsigned, so the error path
> wasn't taken when irq_of_parse_and_map() returned an incorrect irq.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com> 

This test is way too convoluted for my taste.

I would rather that the implementations of this interface
use a consistent value for errors.  Preferrably NO_IRQ.

Not applied.
