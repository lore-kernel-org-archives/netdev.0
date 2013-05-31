From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Thu, 30 May 2013 18:11:28 -0700
Message-ID: <1369962688.1751.6.camel@buesod1.americas.hpqcorp.net>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
	 <51A6768B.5050603@cogentembedded.com> <87obbsohd1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87obbsohd1.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-30 at 13:08 +0200, Bj=C3=B8rn Mork wrote:
> Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:
>=20
> >     Why not "text:%#lx" as already used in this string? It's
> > equivalent to "0x%lx".
>=20
> Well, I don't know the reasoning in this case, but I'd like to note t=
hat
> those are not strictly equivalent.  Personally I find the formatting =
of 0
> annoying enough to avoid %#x for any value which may be 0.  It's
> especially bad if you try to line up things by adding leading zeros.

Yep, I found that 0x%lx produced the same output as %p. If you'd rather
I use something else instead, I'm happy to update the patch.

Thanks,
Davidlohr
