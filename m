From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Fri, 12 Oct 2012 16:16:06 +0200
Message-ID: <20121012161606.4cb97b48@skate>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<5076E9F1.60200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Rami Rosen <rosenr@marvell.com>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:44319 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932762Ab2JLOQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:16:26 -0400
In-Reply-To: <5076E9F1.60200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob,

On Thu, 11 Oct 2012 10:46:57 -0500, Rob Herring wrote:

> > +Required properties:
> > +- compatible: should be "marvell,neta".
> 
> This should be more specific such as "marvell,armada-xp-neta".
> 
> Or use 370 instead of xp. It should be which ever chip came first.

Is this really useful? The name of this network unit in Marvell is
simply "neta", and since it is associated with the vendor name Marvell
in the compatible string, it is actually unique: "marvell,neta".

The thing is that this unit is used in Armada 370, Armada XP, but also
other SoCs (which I am not sure are announced publicly as of today). So
if possible, we would prefer to keep the proposed "marvell,neta" name.
We could also change it to "marvell,ebu-neta" where EBU stands for
Embedded Business Unit, just like the "ebu" in arch/arm/mach-mvebu/,
but it sounds more logical to have just "marvell,neta".

Thanks again for your review,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
