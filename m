From: Marc Pignat <marc.pignat@hevs.ch>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 4 Nov 2008 16:45:39 +0100
Message-ID: <200811041645.39953.marc.pignat@hevs.ch>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hevs.ch ([153.109.23.10]:54050 "EHLO mail.hevs.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbYKDPpr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 10:45:47 -0500
In-Reply-To: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi=C3=BC

On Tuesday 04 November 2008, Paulius Zaleckas wrote:
> make mdio-gpio work with non OpenFirmware gpio implementation.

of_gpio.c provides generic gpio compatible gpios.

Why not remove all OF specific code from this file and add another one
creating the struct mdio_gpio_platform_data using OF specific functions=
?

Best regards

Marc
