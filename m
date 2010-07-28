From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH net-next] drivers/net/bfin_mac.c: Use
	pr_fmt, netdev_<level>
Date: Wed, 28 Jul 2010 03:50:31 -0400
Message-ID: <AANLkTi=p=-ovBaqyqBdEW=W4E1ArWsiyUBwy37GtXOyu@mail.gmail.com>
References: <1280258531.24054.10.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280258531.24054.10.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 27, 2010 at 15:22, Joe Perches wrote:
> And some assorted neatening for checkpatch:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A080 column reformatting (mostly comments)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0argument alignment
> =C2=A0 =C2=A0 =C2=A0 =C2=A0couple of spelling/grammar typos corrected
>
> Added bfin_alloc_skb to centralize allocation/dcache invalidation
> Added get_mac_addr for symmetry
>
> $ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total:"
> total: 2 errors, 25 warnings, 1723 lines checked
> $ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total:"
> total: 0 errors, 0 warnings, 1743 lines checked
>
> Uncompiled, untested.

i dislike the mixing of whitespace and useful changes

if they were split, and they worked, then i wouldnt have a problem with=
 them
-mike
