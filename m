From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: use after free bug in socket code
Date: Tue, 14 Jul 2009 19:53:42 +0200
Message-ID: <4A5CC626.8020800@grandegger.com>
References: <19028.16049.907160.45293@ipc1.ka-ro>	<20090709154533.GA27413@gondor.apana.org.au>	<19035.23045.386506.297464@ipc1.ka-ro>	<4A5B730B.8090902@hartkopp.net>	<19036.9400.263297.330963@ipc1.ka-ro>	<4A5C990E.3080703@hartkopp.net> <19036.41388.634723.358236@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: =?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:56207 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543AbZGNRxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 13:53:47 -0400
In-Reply-To: <19036.41388.634723.358236@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lothar Wa=DFmann wrote:
> Hi,
>=20
> Oliver Hartkopp writes:
>>> The situation where this triggers a bug is when the chip driver's
>>> hard_start_xmit function returns a NETDEV_TX_BUSY and subsequently =
the
>>> can interface is deconfigured.
>>>
>>> Maybe you could try this on different hardware?
>> Will do when i'm back at work ;-)
>>
> Should I wait for the results of your tests before submitting the
> patches?

A user has reported sporadic kernel panics with a down/up/restart stres=
s
test a while ago on the Socket-CAN mailing list and the patch seems to
solve his problem:

https://lists.berlios.de/pipermail/socketcan-users/2009-July/000985.htm=
l

=46rom my point of view you can go ahead.

Thanks.

Wolfgang.
