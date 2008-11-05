From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Wed, 5 Nov 2008 15:03:50 -0800
Message-ID: <200811051503.51040.david-b@pacbell.net>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <8bd0f97a0811050032i206214a6r8d30a58f354995b4@mail.gmail.com> <200811050957.25821.marc.pignat@hevs.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Mike Frysinger" <vapier.adi@gmail.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: Marc Pignat <marc.pignat@hevs.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.sbc.mail.mud.yahoo.com ([68.142.198.204]:24734 "HELO
	smtp105.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753295AbYKEXKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:10:35 -0500
In-Reply-To: <200811050957.25821.marc.pignat@hevs.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 November 2008, Marc Pignat wrote:
> This is why I proposed to split the driver in two parts (gpio only mdio
> driver + OF platform device). Just treating OF GPIO as any other GPIO.

I think that's overall a much cleaner approach too.  Keeps
OF's hardware abstraction layer out of drivers.

But for some reason the OF folk don't like that model.
It comes up repeatedly, with lots of frameworks and their
drivers.

