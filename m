From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Support 100Mbps when accessed via timberdale
Date: Sun, 25 Jul 2010 17:03:27 -0700 (PDT)
Message-ID: <20100725.170327.226755551.davem@davemloft.net>
References: <1280091327.17191.8.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818Ab0GZADK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 20:03:10 -0400
In-Reply-To: <1280091327.17191.8.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Sun, 25 Jul 2010 22:55:27 +0200

> The flow control setting is removed from TX and RX control
> registers. Full duplex flow control was not enabled in SGCR3,
> but we tend to get better performance without flow control.

=46low control is not just for you, it's for the other end too.

If you're getting bad flow control enabled performance then
either:

1) the flow control is configured to kick in too late or
   too soon

or

2) your ring sizes need adjustment

I'm not applying this patch, flow control is important and
should be enabled by default whenever possible.  Please
instead go try and figure out if flow control trigger
points or RX/TX ring sizes need adjustment instead.

Thanks.
