From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next 1/2] inetpeer: add namespace support for inetpeer
Date: Tue, 05 Jun 2012 13:58:03 +0800
Message-ID: <4FCD9FEB.9060208@cn.fujitsu.com>
References: <1338863012-4902-1-git-send-email-gaofeng@cn.fujitsu.com> <1338867619.2760.1980.camel@edumazet-glaptop> <20120605055208.GA27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12545 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab2FEF5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:57:36 -0400
In-Reply-To: <20120605055208.GA27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8805=E6=97=A5 13:52, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Tue, Jun 05, 2012 at 05:40:19AM +0200, Eric Dumazet wrote:
>> On Tue, 2012-06-05 at 10:23 +0800, Gao feng wrote:
>>> =20
>>> +static int __net_init inetpeer_net_init(struct net *net)
>>> +{
>>> +
>>> +	net->ipv4.peers =3D kmemdup(&v4_peers,
>>> +				  sizeof(v4_peers),
>>> +				  GFP_KERNEL);
>>
>> kzalloc(), and init ->root to peer_avl_empty_rcu
>>
>>> +	if (net->ipv4.peers =3D=3D NULL)
>>> +		return -1;
>=20
> ...and return -ENOMEM if memory allocation fails.

thanks Eric & Steffen
I miss it... I will fix it and send patch v2.
