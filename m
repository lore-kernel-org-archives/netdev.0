From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Thu, 13 Aug 2009 13:13:28 -0700 (PDT)
Message-ID: <20090813.131328.70892070.davem@davemloft.net>
References: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
	<20090812.145549.228391386.davem@davemloft.net>
	<4A8409CA.70200@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slot.daniel@gmail.com, netdev@vger.kernel.org
To: hannemann@nets.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755895AbZHMUNS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 16:13:18 -0400
In-Reply-To: <4A8409CA.70200@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date: Thu, 13 Aug 2009 14:40:42 +0200

> David Miller schrieb:
>> From: Daniel Slot <slot.daniel@gmail.com>
>> Date: Wed, 12 Aug 2009 20:47:44 +0200
>>=20
>>> RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
>>> In the absence of explicit congestion notification from the network=
, TCP
>>> uses loss as an indication of congestion.
>>> One of the ways TCP detects loss is using the arrival of three dupl=
icate
>>> acknowledgments.
>>> However, this heuristic is not always correct,
>>> notably in the case when network paths reorder segments (for whatev=
er
>>> reason), resulting in degraded performance.
>>=20
>> Linux's TCP stack already has sophisticated reordering detection.=E4
>=20
>=20
> Hmm, sophisticated? Sorry, it seemed pretty rudimental/random to me.

It's more sophisticated than what you're proposing, which is a hammer
which requires intervention on the part of the application.
