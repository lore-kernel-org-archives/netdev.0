From: Steffen Sledz <sledz@dresearch.de>
Subject: Re: [PATCH resent] tcp: ioctl type SIOCOUTQNSD returns amount of
 data not sent
Date: Fri, 04 Mar 2011 10:51:29 +0100
Message-ID: <4D70B621.7020307@dresearch.de>
References: <1299228497-21246-1-git-send-email-sledz@dresearch.de> <20110304.010428.71127798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.schuknecht@dresearch.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110304.010428.71127798.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 04.03.2011 10:04, schrieb David Miller:
> From: Steffen Sledz <sledz@dresearch.de>
> Date: Fri,  4 Mar 2011 09:48:17 +0100
>=20
>> diff --git a/include/asm-generic/ioctls.h b/include/asm-generic/ioct=
ls.h
>> index 199975f..ef2be0b 100644
>> --- a/include/asm-generic/ioctls.h
>> +++ b/include/asm-generic/ioctls.h
>> @@ -74,6 +74,7 @@
>>  #define TCSETXW		0x5435
>>  #define TIOCSIG		_IOW('T', 0x36, int)  /* pty: generate signal */
>>  #define TIOCVHANGUP	0x5437
>> +#define TIOCOUTQNSD	0x5438
>> =20
>>  #define FIONCLEX	0x5450
>>  #define FIOCLEX		0x5451
>=20
> Hitting only asm-generic/ioctls.h is insufficient, many architectures=
 do
> not make use of this file and the build will fail for them with your =
patch
> applied.

That's not fully clear to me.

We made the define similar to the existing TIOCOUTQ. What other files s=
hould be hit?

Steffen Sledz

--=20
DResearch Fahrzeugelektronik GmbH
Otto-Schmirgal-Str. 3, 10319 Berlin, Germany
Tel: +49 30 515932-237 mailto:sledz@DResearch.de
=46ax: +49 30 515932-299
Gesch=E4ftsf=FChrer: Dr. Michael Weber, Werner M=F6gle;
Amtsgericht Berlin Charlottenburg; HRB 130120 B;
Ust.-IDNr. DE273952058
