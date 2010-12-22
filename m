From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Wed, 22 Dec 2010 15:06:24 +0800
Message-ID: <4D11A370.9060901@cn.fujitsu.com>
References: <4CF75BC3.1020606@cn.fujitsu.com>	<20101216.121805.59690737.davem@davemloft.net>	<4D0EF840.2020108@cn.fujitsu.com> <20101219.224350.260095315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: albertpretorius@yahoo.co.uk, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64883 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab0LVHIW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:08:22 -0500
In-Reply-To: <20101219.224350.260095315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, at 12/20/2010 02:43 PM:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Mon, 20 Dec 2010 14:31:28 +0800
>=20
>> David Miller wrote, at 12/17/2010 04:18 AM:
>>> Your approach will only modify socket based route handling, it will
>>> not handle the ipv6 forwarding case which as per the quoted RFC
>>> sections must be handled too.
>>
>> For the ipv6 forwarding case, we have done the check in ip6_forward(=
).
>>
>>  493                 int addrtype =3D ipv6_addr_type(&hdr->saddr);
>>  494=20
>>  495                 /* This check is security critical. */
>>  496                 if (addrtype =3D=3D IPV6_ADDR_ANY ||
>>  497                     addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR=
_LOOPBACK))
>>  498                         goto error;
>=20
> Indeed, thanks for pointing this out.

Notice that the state in patchwork is =E2=80=9CChanges Requested=E2=80=9D=
, what should i do=20
now?  I have no idead which part of this patch should be changed.

--=20
Best Regards
-----
Shan Wei
