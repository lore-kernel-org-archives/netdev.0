From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] DM9000 interrupt is hardware dependant
Date: Mon, 4 Sep 2006 22:46:46 +0200
Message-ID: <20060904204646.GD3782@xi.wantstofly.org>
References: <200609042217.09004.linux@schindele.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:28297 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751285AbWIDUqs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 16:46:48 -0400
To: =?iso-8859-1?Q?J=FCrgen?= Schindele <linux@schindele.name>
Content-Disposition: inline
In-Reply-To: <200609042217.09004.linux@schindele.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2006 at 10:17:08PM +0200, J=FCrgen Schindele wrote:

> i made a patch for an PXA270-evalboard with DM9000
> ethernet contoller. The Interrupt can be high- or low-
> active dependant of the wiring of the MDC-(57)pin.
>=20
> Because of this hardware dependency you shoud be able
> to configure this behaviour in "struct resource dm9000_resources[]"

Putting it in 'struct dm9000_plat_data' sounds like a much better
idea to me...

Overloading the IRQ number in 'struct resource' is just ugly.


cheers,
Lennert
