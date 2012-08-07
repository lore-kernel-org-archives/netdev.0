From: Ian Molton <ian.molton@codethink.co.uk>
Subject: Re: [PATCH v3 3/7] mv643xx.c: Add basic device tree support.
Date: Tue, 07 Aug 2012 16:56:59 +0100
Message-ID: <50213ACB.6040301@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <1344350092-24050-4-git-send-email-ian.molton@codethink.co.uk> <201208071456.41412.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:52071 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab2HGP5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 11:57:10 -0400
In-Reply-To: <201208071456.41412.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/12 15:56, Arnd Bergmann wrote:

> Hi Ian,
>
> Have you had a look at Documentation/devicetree/bindings/marvell.txt
> ?

Nope. I had no idea it was hiding there.

> I think it documents some of the same thing,

Not really. It documents some godawful hack that recycled the platform
device -based driver and provided a DT binding for it, just for PPC.

I cant even *find* anything that implements code for whatever
"marvell,mv64360-mdio" might be. I'm sure it might exist somewhere.

> We might also want to move some of the
> code from arch/powerpc/sysdev/mv64x60_dev.c to live in the same place
> as the device driver.

I hope not. I don't really want to touch that stuff at all. If it works
the way it
is, then it can stay that way. If the PPC folk want to send patches to
add the
properties they use to the driver, then they can do. I'll send an email
their
way and see if they want to join in.

>From my perspective, the next thing that needs to happen to the driver is
for it to be broken up into ethernet and mdio drivers, so that we can
get rid
of all this shared_smi craziness... But that's for another patch series.

-Ian
