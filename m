From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v2] ip_tunnel: enclose a code block in macro IS_ENABLED(CONFIG_IPV6)
Date: Tue, 24 May 2016 11:55:31 +0800
Message-ID: <4A265D43-913E-449E-8BA0-80A2B6930AD6@cmss.chinamobile.com>
References: <1464057597-3648-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <1464059658.5939.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464059658.5939.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On May 24, 2016, at 11:14 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>=20
> On Tue, 2016-05-24 at 10:39 +0800, Haishuang Yan wrote:
>> For ipv6 case, enclose the code block in macro IS_ENABLED(CONFIG_IPV=
6).
>>=20
>> ---
>> Changes in v2:
>>  - Place the "#if IS_ENABLED" block before the "} else if
>> (..) {" piece and the "#endif" before the closing brace and this
>> becomes much easier to look at.
>=20
> _Why_ is this patch needed ?
>=20
> Please describe in the changelog what _actual_ problem you are trying=
 to
> address.
>=20
> We have many points in the kernel using ipv6_get_dsfield() even if
> CONFIG_IPV6=3Dn, and it seems fine to me at least.
>=20
> Thanks.
>=20
>=20
>=20

Yes, you=A1=AFre right, but I think add this patch seems more reasonabl=
e in coding.

Thanks for your reviewing.
