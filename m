From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 08:29:51 +0100
Message-ID: <4AE6A16F.4020002@gmail.com>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com> <4AE68E23.20205@gmail.com> <4AE69829.9070207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756036AbZJ0HaH@vger.kernel.org>
In-Reply-To: <4AE69829.9070207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
>=20
>=20
> 511 value on 64bit, and 1023 on 32bit arches are nice because
> hashsz * sizeof(pointer) <=3D 4096, wasting space for one pointer onl=
y.
>=20
> Conclusion : jhash and 511/1023 hashsize for netdevices,
> no divides, only one multiply for the fold.

Just forget about 511 & 1023, as power of two works too.

-> 512 & 1024 + jhash

Guess what, David already said this :)
