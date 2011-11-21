From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 21 Nov 2011 15:21:02 +0100
Message-ID: <20111121142102.GA1676@x4.trippels.de>
References: <20111118075521.GB1615@x4.trippels.de>
 <1321605837.30341.551.camel@debian>
 <20111118085436.GC1615@x4.trippels.de>
 <20111118120201.GA1642@x4.trippels.de>
 <1321836285.30341.554.camel@debian>
 <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "Alex,Shi" <alex.shi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 2011.11.21 at 15:16 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 =E0 14:15 +0100, Markus Trippelsdorf a =E9cri=
t :
>=20
> > I've enabled CONFIG_SLUB_DEBUG_ON and this is what happend:
> >=20
>=20
> Thanks
>=20
> Please continue to provide more samples.
>=20
> There is something wrong somewhere, but where exactly, its hard to say.
>=20
> Something is keeping a pointer to freed memory and reuse it while memor=
y
> had been reused.
>=20
> Are you using hugepages ?

Only CONFIG_TRANSPARENT_HUGEPAGE and CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS.

I've increased LOG_BUF_SHIFT to 18, because it looks like the beginning
of the SLUB_DEBUG output was cut off last time.

--=20
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
