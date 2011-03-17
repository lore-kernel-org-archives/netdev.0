From: "avictor.za@gmail.com" <avictor.za@gmail.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Thu, 17 Mar 2011 10:43:09 +0200
Message-ID: <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-4-git-send-email-jamie@jamieiles.com>
	<87vczkmy94.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	plagnioj@jcrosoft.com, nicolas.ferre@atmel.com,
	linux-arm-kernel@lists.infradead.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39712 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab1CQInK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:43:10 -0400
Received: by bwz15 with SMTP id 15so2259711bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 01:43:09 -0700 (PDT)
In-Reply-To: <87vczkmy94.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

> =A0Jamie> Both at91 and avr32 defines its own platform data structure=
 for
> =A0Jamie> the macb driver and both share common structures though at9=
1
> =A0Jamie> includes a currently unused phy_irq_pin. =A0Create a common
> =A0Jamie> eth_platform_data for macb that both at91 and avr32 can use=
=2E =A0In
> =A0Jamie> future we can use this to support other architectures that =
use the
> =A0Jamie> same IP block with the macb driver.
>
> How about at the same time renaming it to something a bit less generi=
c
> like macb_platform_data?

The AT91RM9200 uses the same platform_data structure, but has a
different Ethernet peripheral (ie, not the MACB)

The phy_irq_pin is used in the AT91RM9200 ethernet driver.
(drivers/net/arm/at91_ether.c)


Regards,
  Andrew Victor
