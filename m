From: Steffen Sledz <sledz@dresearch.de>
Subject: Re: [PATCH v2] tcp: ioctl type SIOCOUTQNSD returns amount of data
 not sent
Date: Fri, 04 Mar 2011 13:26:53 +0100
Message-ID: <4D70DA8D.9070603@dresearch.de>
References: <201103041057.53671.arnd@arndb.de> <1299234031-13937-1-git-send-email-sledz@dresearch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mario Schuknecht <m.schuknecht@dresearch.de>,
	Steffen Sledz <sledz@dresearch.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299234031-13937-1-git-send-email-sledz@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 04.03.2011 12:49, schrieb Alan Cox:
> ...
>>> Signed-off-by: Mario Schuknecht <m.schuknecht@dresearch.de>
>>> ---
>>>  include/asm-generic/ioctls.h |    1 +
>>>  include/linux/sockios.h      |    1 +
>>>  net/ipv4/tcp.c               |    9 +++++++++
>>>  3 files changed, 11 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/asm-generic/ioctls.h b/include/asm-generic/ioc=
tls.h
>>> index a321665..b87115b 100644
>>> --- a/include/asm-generic/ioctls.h
>>> +++ b/include/asm-generic/ioctls.h
>>> @@ -72,6 +72,7 @@
>>>  #define TCSETXF		0x5434
>>>  #define TCSETXW		0x5435
>>>  #define TIOCSIG		_IOW('T', 0x36, int)  /* pty: generate signal */
>>> +#define TIOCOUTQNSD	0x5437
>
> These are tty not socket ioctl codes. For various historical reasons =
some
> of them got sort of emulated by the socket layer in Unix and thus in
> Linux.
>
> If you plan to add one to Linux then please post the accompanying *tt=
y
> layer* patches and reasoning, otherwise if it is socket only please s=
tick
> to the socket ioctl.

So we should define the new SIOCOUTQNSD in sockios.h only and not simil=
iar to SIOCOUTQ using TIOCOUTQ. Right?

Steffen

--=20
DResearch Fahrzeugelektronik GmbH
Otto-Schmirgal-Str. 3, 10319 Berlin, Germany
Tel: +49 30 515932-237 mailto:sledz@DResearch.de
=46ax: +49 30 515932-299
Gesch=E4ftsf=FChrer: Dr. Michael Weber, Werner M=F6gle;
Amtsgericht Berlin Charlottenburg; HRB 130120 B;
Ust.-IDNr. DE273952058
