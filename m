From: Andre Tomt <andre@tomt.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 05 Feb 2005 12:48:15 +0100
Message-ID: <4204B27F.5040202@tomt.net>
References: <20050204213813.4bd642ad.davem@davemloft.net>	<20050205061110.GA18275@gondor.apana.org.au>	<4204AA7C.9010509@tomt.net> <20050205.203900.66065862.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: andre@tomt.net, herbert@gondor.apana.org.au, davem@davemloft.net,
        mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, shemminger@osdl.org
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050205.203900.66065862.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <4204AA7C.9010509@tomt.net> (at Sat, 05 Feb 2005 12:14:04 +0=
100), Andre Tomt <andre@tomt.net> says:
>=20
>=20
>>This patch fixes my problems with hangs when dot1q VLAN interfaces gets=
=20
>>removed when loopback is down, as reported in the thread "2.6.10=20
>>ipv6/8021q lockup on vconfig on interface removal".
>=20
>=20
> Please tell me, why your lo is down...
>=20
> Anyway, if we really want to "fix" this,
> we should do in other way.
>=20
> I think "Make loopback idev stick around" patches
> (for IPv4 and IPv6) could be start of that.

"ifdown -a" gets run on shutdown and reboot here, and ifdown -a in=20
Debian brings down loopback before any other interfaces.
