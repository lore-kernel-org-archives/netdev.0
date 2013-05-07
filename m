From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 07 May 2013 07:17:54 -0400 (EDT)
Message-ID: <20130507.071754.1017228470154155643.davem@davemloft.net>
References: <1367920728.4126.32.camel@weser.hi.pengutronix.de>
	<CAHrpEqQFeqzyjT6EgzULZVC-bQU_juUMddBzuMfoN7+jppF2MQ@mail.gmail.com>
	<1367921617.4126.36.camel@weser.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, Frank.Li@freescale.com, romieu@fr.zoreil.com,
	r.schwebel@pengutronix.de, netdev@vger.kernel.org,
	festevam@gmail.com, shawn.guo@linaro.org
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732Ab3EGLPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 07:15:54 -0400
In-Reply-To: <1367921617.4126.36.camel@weser.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Tue, 07 May 2013 12:13:37 +0200

> See Documentation/stable_kernel_rules.txt
> 
> Basically for this patch just add an
> Cc: <stable@vger.kernel.org> # 3.9
> below the sign-off area, but don't actually send the patch there. It
> will get cherry-picked just based on the tag.

That's not how it works for networking, I have a queue of patches
I submit at a time of my own choosing and I do not want people to
add the CC: stable tag.
