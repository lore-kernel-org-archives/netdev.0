From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Mon, 6 Jun 2011 12:48:19 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net> <20110605085948.GB16018@acer>
 <20110605.140801.1144137337172959622.davem@davemloft.net>
 <20110606172607.GB3082@acer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ynezz@true.cz" <ynezz@true.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Mika Westerberg <mika.westerberg@iki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail132.messagelabs.com ([216.82.242.115]:17754 "EHLO
	mail132.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1FFRs3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:48:29 -0400
In-Reply-To: <20110606172607.GB3082@acer>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 06, 2011 10:26 AM, Mika Westerberg wrote:
> On Sun, Jun 05, 2011 at 02:08:01PM -0700, David Miller wrote:
>> From: Mika Westerberg <mika.westerberg@iki.fi>
>> Date: Sun, 5 Jun 2011 11:59:48 +0300
>> 
>>> It looks like David Miller (CC'd) has been taking care of ep93xx_eth.c maybe
>>> he knows this better.
>> 
>> Someone needs to step up and take over as the real maintainer of this
>> driver.  The way the driver is currently being hacked on is
>> unsustainable.
>
> Can't agree more.
>
> Hartley, Ryan: do you have any preferences? Are you guys already overwhelmed
> with your current maintenance work, or could you consider taking this one as
> well? 
>
> If no one else steps up, I can volunteer but I have to admit that I don't know
> much about that driver.

I feel the same way.

If Lennert is no longer maintaining the this driver we really need someone to
step up and handle it.

I have no problem doing it but I really don't have a good grasp on the driver
or the whole network subsystem.

If Lennert is willing to hand it over, I have no problem being listed as a
co-maintainer along with either yourself of Ryan.  Between the two (or three)
of us we should be able to handle it.


Lennert,

You are listed as the maintainer for these EP93xx related pieces:

ARM/CIRRUS LOGIC EDB9315A MACHINE SUPPORT
CIRRUS LOGIC EP93XX ETHERNET DRIVER
CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER

I can take over the edb9315a with no problem.  It actually falls under
arch/arm/mach-ep93xx, so the entry could just be removed from MAINTAINERS.

For the OHCI driver, I'm in the same boat as the Ethernet.  If you are no longer
maintaining this driver I'm willing to handle it but would like someone to step
up as a co-maintainer.  Hopefully someone that has some grasp of that subsystem.

Your also listed in the source as the maintainer of these ep93xx boards:

ADSSPHERE	adssphere.c
EDB9302A	edb93xx.c
EDB9315	edb93xx.c
EDB9315A	edb93xx.c
GESBC9312	gesbc9312.c
TS72XX	ts72xx.c

I'm willing to handle those also since they are under arch/arm/mach-ep93xx.

Regards,
Hartley
