From: Andreas Steffen <andreas.steffen@strongswan.org>
Subject: Re: [PATCHv2] xfrm: fix xfrm by MARK logic
Date: Sat, 03 Jul 2010 09:02:33 +0200
Message-ID: <4C2EE089.6040604@strongswan.org>
References: <20100702174755.GA12509@myhost> <1278139083.2474.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Peter Kosyh <p.kosyh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80024.hsr.ch ([152.96.80.24]:42810 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201Ab0GCHCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 03:02:36 -0400
In-Reply-To: <1278139083.2474.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Great,

this was the second bug [besides the xfrm_mark_get issue] I was looking
for this week and which prevented strongSwan from successfully using
mark-based IPsec policies. It works like a charm now.

Thanks!

On 07/03/2010 08:38 AM, Eric Dumazet wrote:
> Le vendredi 02 juillet 2010 =C3=A0 21:47 +0400, Peter Kosyh a =C3=A9c=
rit :
>> From: Peter Kosyh <p.kosyh@gmail.com>
>>
>> While using xfrm by MARK feature in
>> 2.6.34 - 2.6.35 kernels, the mark=20
>> is always cleared in flowi structure via memset in=20
>> _decode_session4 (net/ipv4/xfrm4_policy.c), so
>> the policy lookup fails.
>> IPv6 code is affected by this bug too.
>>
>> Signed-off-by: Peter Kosyh <p.kosyh@gmail.com>
>> ---
>>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Thanks !

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Andreas Steffen                         andreas.steffen@strongswan.org
strongSwan - the Linux VPN Solution!                www.strongswan.org
Institute for Internet Technologies and Applications
University of Applied Sciences Rapperswil
CH-8640 Rapperswil (Switzerland)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D[ITA-HSR]=3D=3D
