From: Nicolas Cannasse <ncannasse@motion-twin.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Mon, 13 Oct 2008 20:48:37 +0200
Message-ID: <48F39805.1000308@motion-twin.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>	<alpine.LFD.2.00.0810052008131.3398@apollo>	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
 	<alpine.LFD.2.00.0810082154420.3237@apollo>	<48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>	<Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi> <48f39456.060ec00a.1389.4433@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns0.motion-twin.com ([213.186.50.39]:51112 "EHLO
	mail.motion-twin.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755485AbYJMToE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 15:44:04 -0400
In-Reply-To: <48f39456.060ec00a.1389.4433@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

D=E2niel Fraga a =E9crit :
> On Mon, 13 Oct 2008 16:35:08 +0300 (EEST)
> "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
>=20
>> http://marc.info/?t=3D122365716200001&r=3D1&w=3D2
>>
>> ...might turn out related. It has somewhat similar problem though=20
>> different syscall. Not enough info on what kernel version etc.=20
>> there though.
>=20
> 	Interesting. I CCed Nicolas Cannasse.
>=20
> 	Nicolas, could you please tell us what kernel version were you
> using when you deal with this problem (from the link above: "recv()
> hangs until SIGCHLD ?")?

2.6.20-15-server #2 SMP

Best,
Nicolas


