From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
Date: Sat, 26 Nov 2011 11:59:22 +0100
Message-ID: <1322305162.10212.8.camel@edumazet-laptop>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870967.8173.1.camel@lappy> <1322304878.28191.1.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>,  linux-kernel
 <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1322304878.28191.1.camel@sasha>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le samedi 26 novembre 2011 =C3=A0 12:54 +0200, Sasha Levin a =C3=A9crit :
> > On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
> > >=20
> > > Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer()=
,
> > > here is V2 :
> > >=20
> > > [PATCH] decnet: proper socket refcounting
> > >=20
> > > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure =
we
> > > dont access already freed/reused memory later.
> > >=20
> > > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
> >=20
> >=20
> > Applied locally and running same tests as before, will update with
> > results.
> >=20
>=20
> Looks ok after a couple days of testing.
>=20
> 	Tested-by: Sasha Levin <levinsasha928@gmail.com>
>=20

Thanks Sasha !


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
