From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Mon, 16 May 2016 10:29:44 -0700
Message-ID: <573A0388.2010002@gmail.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20160516.132307.165371654494650235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	kernel@pengutronix.de, afd@ti.com, nm@ti.com
To: David Miller <davem@davemloft.net>, u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33905 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbcEPR3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:29:46 -0400
In-Reply-To: <20160516.132307.165371654494650235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2016 10:23 AM, David Miller wrote:
> From: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> Date: Thu, 12 May 2016 12:00:33 +0200
>=20
>> The framework only asserts (for now) that the reset gpio is not acti=
ve.
>>
>> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de=
>
>=20
> Applied.

Humm that was a little too quick IMHO, there are two concurrent patches
adressing the same problem right now, and Uwe's patch relies on a
specific "quirk" of specifying the Ethernet PHY's full OUI in the Devic=
e
Tree compatible string, while Sergei's approach does not require that..=
=2E
AFAICT, the binding portion of the patch was also still being discussed=
=2E

I guess we will have to submit incremental patches now.
--=20
=46lorian
