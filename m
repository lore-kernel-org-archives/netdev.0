From: Andre Tomt <andre@tomt.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Wed, 09 Feb 2005 21:45:23 +0100
Message-ID: <420A7663.4060308@tomt.net>
References: <20050205064643.GA29758@gondor.apana.org.au>	<20050205104559.GA30981@gondor.apana.org.au>	<20050206114145.GA20883@gondor.apana.org.au> <20050206.213018.92031627.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, shemminger@osdl.org
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050206.213018.92031627.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Oh, you're right! Thanks.
>=20
> How about this; Ignore entries addrconf_dst_alloc'ed entries in rt6_ifd=
own()?
>=20
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

This patch seems to work fine here; cleared out the other patches to be=20
sure. So, herberts first patch fixes it, and so do this one. I have not=20
tried the one in between.
