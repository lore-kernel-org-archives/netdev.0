From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 dead in -bk11
Date: Tue, 02 Nov 2004 10:16:51 -0500
Message-ID: <4187A4E3.8010600@pobox.com>
References: <418781EF.7020100@pobox.com> <20041102.225343.06193184.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040207000109040401090605"
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        akpm@osdl.org, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041102.225343.06193184.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040207000109040401090605
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id iA2FJLvD000625

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <418781EF.7020100@pobox.com> (at Tue, 02 Nov 2004 07:47:43 -=
0500), Jeff Garzik <jgarzik@pobox.com> says:
>=20
>=20
>>IPv6 works 100% for my workstations in 2.6.10-rc2-bk2, but fails in=20
>>2.6.10-rc2-bk11:
>>
>>	[jgarzik@sata g]$ ping6 www.kame.net
>>	connect: Network is unreachable
>=20
>=20
> Please send me:
>  % ifconfig -a
>  % netstat -nr --inet6
>  % ip -6 addr
>  % ip -6 route
>  % ip -6 neigh
>=20
> Thanks.
>=20
> --yoshfuji @ still trying to debug refcnt etc....

Done, see attached.

ipv6/working/* is 2.6.10-rc1-bk2, and ipv6/dead/* is 2.6.10-rc1-BK-curren=
t.

	Jeff


--------------040207000109040401090605
Content-Type: application/x-bzip2;
 name="ipv6-output.tar.bz2"
Content-Disposition: inline;
 filename="ipv6-output.tar.bz2"
Content-Transfer-Encoding: base64

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
--------------040207000109040401090605--
