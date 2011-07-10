From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 02/21] net: 3c59x: use common rx_copybreak handling
Date: Sun, 10 Jul 2011 09:24:54 +0200
Message-ID: <20110710072454.GA5825@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <5a242c5dbd6222d87b77a22b9c6fe6cdfa0351f3.1310229312.git.mirq-linux@rere.qmqm.pl> <20110709222258.GA5642@electric-eye.fr.zoreil.com> <20110709232339.GA15588@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47319 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352Ab1GJHjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 03:39:18 -0400
Content-Disposition: inline
In-Reply-To: <20110709232339.GA15588@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> For this driver and via-velocity - you're right (fixed). For others n=
o -
> they always refill the rx ring, possibly discarding the packet.

Ok, I completely missed the "_refill" part.

--=20
Ueimor
