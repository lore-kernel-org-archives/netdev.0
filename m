From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/sched/act_nat.c BUG
Date: Sat, 10 Jul 2010 08:27:21 +0200
Message-ID: <1278743241.2538.28.camel@edumazet-laptop>
References: <201007091637.57660.rpartearroyo@albentia.com>
	 <1278688420.2696.7.camel@edumazet-laptop>
	 <20100709232359.GA2501@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rodrigo Partearroyo =?ISO-8859-1?Q?Gonz=E1lez?=
	<rpartearroyo@albentia.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	Noelia =?ISO-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100709232359.GA2501@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 10 juillet 2010 =C3=A0 07:23 +0800, Herbert Xu a =C3=A9crit :

> No we do need the second IP header, think about it...
>=20
> However, we should only drop it only if it's long enough and
> pskb_may_pull fails.

Indeed right you are !

As Changli suggested, we need another pskb_may_pull() call.

Thanks
