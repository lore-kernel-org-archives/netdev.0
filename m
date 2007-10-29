From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: drivers/net/sunhme.c patch
Date: Mon, 29 Oct 2007 23:12:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0710292311070.32301@fbirervta.pbzchgretzou.qr>
References: <4725F416.2030100@wonderland.us.com>
 <Pine.LNX.4.64.0710291606260.26070@fbirervta.pbzchgretzou.qr>
 <20071029.151025.87460351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: toms@wonderland.us.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:49301 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbXJ2WM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:12:26 -0400
In-Reply-To: <20071029.151025.87460351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 29 2007 15:10, David Miller wrote:
>> On Oct 29 2007 08:54, Tom Southerland wrote:
>> >
>> > This patch provides a unique mac address for all interfaces
>> > for the Sun QFE card (non-sparc).  It takes the base mac from
>> > the first interface and increments the mac address for the
>> > other interfaces.
>> 
>> Where is the difference to a SPARC QFE? PCI is PCI after all, is not it?
>
>To answer the question, yes it is just a normal PCI device, they put 4
>HME chips behind a PCI bridge.  However, the OpenFirmware on the cards
>usually creates device node properties for these PCI devices for the
>local ethernet addresses.  That's what he's trying to duplicate here.
>
The question was more like: if I put in a QFE (that was acquired together
with a SUN E250) into x86, would I get duplicate MACs? (Would be strange -
I would have supposed the OF on the card is independent.)

