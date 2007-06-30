From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 23:53:25 +0200
Message-ID: <200706302353.25426.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: "=?iso-8859-1?q?T=F6r=F6k?= Edvin" <edwintorok@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39508
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998AbXF3VyK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 17:54:10 -0400
In-Reply-To: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 30 June 2007 13:47:35 T=F6r=F6k Edvin wrote:
> When the interface is down (or driver removed), the BroadCom 44xx car=
d remains
> powered on, and both its MAC and PHY is using up power.
> This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the inter=
face
> is halted, and does a partial chip reset turns off the activity LEDs =
too.
>=20
> Applies to 2.6.22-rc6, or current git head.
>=20
> Tested on a Broadcom BCM4401-B0 card, it saves ~0.5W (measured using =
powertop).

Hm, I was going to measure the real power advantage with a
PCI-extender card. But my B44B0 card doesn't seem to work in
that extender card. It works perfectly fine sticked directly into
the motherboard, though, and other cards like a BCM4318 work in
the extender, too.
Not sure what this is.
The extender has an application note about nonworking cards in the
extender and a too big resistor on the board IDSEL pin being the
cause of this.
Maybe I can try with another machine tomorrow.

--=20
Greetings Michael.
