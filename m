From: Andre Tomt <andre@tomt.net>
Subject: Re: [PATCH/RFC] PATCH: IPV6: Fix multiple leakages (is Re: unregister_netdevice:
 waiting for tun6to4 to become free.)
Date: Fri, 24 Sep 2004 22:51:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415488BA.7020609@tomt.net>
References: <41527796.4010204@tomt.net>	<4152843D.6010204@tomt.net>	<20040923.172253.125681726.yoshfuji@linux-ipv6.org> <20040925.040506.106641510.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, tgraf@suug.ch, pp@ee.oulu.fi, jgarzik@pobox.com,
        dwmw2@infradead.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040925.040506.106641510.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>>Thank you everyone for tracking down this bug.
>>I will fix this bug and come up with patch tomorrow (or so).
>=20
> Well, I've created changesets which should fix multiple leakages.
> Here's the snapshot.  Please review.

I applied the following set to my internal 2.6.8.1 tree;
> ChangeSet@1.2006, 2004-09-24 16:29:02+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] Don't multiply join multicast/anycast addresses.

It fixed my problem, thanks :-)

Unless someone convinces me it has ill-effects with whats in the 2.6.8.1
ipv6 stack, it will probably go out in a router upgrade push some late
night this weekend.

--=20
Andr=C3=A9 Tomt
