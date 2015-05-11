From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Handle the RXUBR interrupt on all devices
Date: Mon, 11 May 2015 12:10:54 +0200
Message-ID: <5550802E.6040900@atmel.com>
References: <1430856025-1066-1-git-send-email-nathan.sullivan@ni.com> <20150509.160454.1045911244389894144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nathan.sullivan@ni.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150509.160454.1045911244389894144.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/05/2015 22:04, David Miller a =E9crit :
> From: Nathan Sullivan <nathan.sullivan@ni.com>
> Date: Tue, 5 May 2015 15:00:25 -0500
>=20
>> The same hardware issue the at91 must work around applies to at leas=
t the
>> Zynq ethernet, and possibly more devices.  The driver also needs to =
handle
>> the RXUBR interrupt since it turns it on with MACB_RX_INT_FLAGS anyw=
ay.
>>
>> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
>=20
> Applied, thank you.

A v2 of this patch with more explanation in both the commit message and
in code comments had been sent. Not a big deal (I suspect you can't use
the v2 one, now that it's applied in your tree, can you?).

Bye,
--=20
Nicolas Ferre
