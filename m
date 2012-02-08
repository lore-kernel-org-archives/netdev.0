From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: Re: drivers/net/phy/phy.c issue
Date: Wed, 8 Feb 2012 11:30:20 -0800
Message-ID: <1328729420.2261.329.camel@groeck-laptop>
References: <CACW_hTY41xZV6d0W2Z2kRfKOfa+RSQ-A-BoZsZwNXSQmeF_6Gg@mail.gmail.com>
Reply-To: guenter.roeck@ericsson.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "afleming@freescale.com" <afleming@freescale.com>,
	"macro@linux-mips.org" <macro@linux-mips.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Frans Meulenbroeks <fransmeulenbroeks@gmail.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACW_hTY41xZV6d0W2Z2kRfKOfa+RSQ-A-BoZsZwNXSQmeF_6Gg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Copying netdev.

On Wed, 2012-02-08 at 09:31 -0500, Frans Meulenbroeks wrote:
> Hi
> 
> I found an issue with drivers/net/phy/phy.c
> As I could not identify a maintainer for this file I decided to mail
> it to the above addressees.
> Apologies upfront if it is inappropriate.
> 
> The issue:
> 
> My network interface was configured as 10Mbit, full duplex, autonegotiate off.
> If the cable is unplugged after 10 seconds or so the interface drops
> to half duplex and the message:
> Trying 10/HALF
> is printed. This message comes (if I am correct from the function
> phy_force_reduction in drivers/net/phy/phy.c
> 
> Maybe this is still ok, however if I reconnect my network cable the
> interface remains configured as 10 Mbit, half duplex.
> I had expected/assumed that it would go back to 10 Mbit, full duplex.
> 
> If I try the same with a 1Gbit full duplex link with autonegotiate on,
> the link also drops to half duplex whenever the cable is
> disconnected. However reconnecting the cable then brings the interface
> back to full duplex again.
> 
> Not sure what is wrong (if the interface should not be dropped to half
> or get back to full) and even less an idea how to fix it,
> but wanted to report it anyway, in the hope someone can shed a light
> on this and/or fix it.
> 
What is your kernel version ? No idea if it makes a difference, but I
strongly suspect people will need to know.

Guenter

> Best regards, Frans.
> 
> PS: I'm not on lkml (way too much mails for me), so please keep me on Cc
