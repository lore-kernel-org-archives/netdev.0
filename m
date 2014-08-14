From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: Parent device of MDIO bus
Date: Thu, 14 Aug 2014 08:16:19 +0200
Message-ID: <m3a977wq8c.fsf@t19.piap.pl>
References: <m3egwkwl9v.fsf@t19.piap.pl>
	<CAOMZO5CAfLYq_LTHMhemHY1GZKFYEs-ucW313F9CmpTjWRdNig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:54188 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbaHNGQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 02:16:22 -0400
In-Reply-To: <CAOMZO5CAfLYq_LTHMhemHY1GZKFYEs-ucW313F9CmpTjWRdNig@mail.gmail.com>
	(Fabio Estevam's message of "Wed, 13 Aug 2014 12:43:14 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I noticed a recent change a71e3c37960ce5f9c6a519bc1215e3ba9fa83e75:
>>     net: phy: Set the driver when registering an MDIO bus device
>>
>>     mdiobus_register() registers a device which is already bound to a driver.
>>     Hence, the driver pointer should be set properly in order to track down
>>     the driver associated to the MDIO bus.
>>
>>     This will be used to allow ethernet driver to pin down a MDIO bus driver,
>>     preventing it from being unloaded while the PHY device is running.

Fabio Estevam <festevam@gmail.com> writes:

> This patch has been reverted in mainline.

Short and simple... Thanks.
-- 
Krzysztof Halasa

Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
