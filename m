From: Marc Pignat <marc.pignat@hevs.ch>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Wed, 5 Nov 2008 09:57:25 +0100
Message-ID: <200811050957.25821.marc.pignat@hevs.ch>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <200811050011.56804.david-b@pacbell.net> <8bd0f97a0811050032i206214a6r8d30a58f354995b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David Brownell" <david-b@pacbell.net>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hevs.ch ([153.109.23.10]:58676 "EHLO mail.hevs.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664AbYKEI5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 03:57:33 -0500
In-Reply-To: <8bd0f97a0811050032i206214a6r8d30a58f354995b4@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 November 2008, Mike Frysinger wrote:
...

> i understand the compiler side just fine.  my point is that the
> current linux/of_gpio.h only defines the OF structure and related
> prototypes when CONFIG_OF_GPIO is defined.  so it needs updating
> first.

This is why I proposed to split the driver in two parts (gpio only mdio
driver + OF platform device). Just treating OF GPIO as any other GPIO.

This will remove all #ifdefs, the same code will be used for OF and non-OF
platforms and defining a platform device is not so complicated.



Best regards

Marc
