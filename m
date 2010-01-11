From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Mon, 11 Jan 2010 18:04:10 +0100
Message-ID: <4B4B5A0A.3090600@gmail.com>
References: <20100110220034.4d46ba8a@nehalam>	<4B4B0AA3.6010207@gmail.com> <20100111082529.3d5cdae3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100111082529.3d5cdae3@nehalam>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 11/01/2010 17:25, Stephen Hemminger a =C3=A9crit :

> We could but:
>   1. GTSM is trying to protect against Man in the Middle attacks to e=
xisting
>      BGP connections
>   2. That is not what BSD (or other vendors) do.

Yes, unfortunately, I am afraid we are forced to be compatable.


>=20
>> Of course, for listeners waiting for connexions from different peers=
 (and different
>> ttl values), it would be tricky.
>>
>> Check should be done at user level, if we store ttl value of SYN pac=
ket and let
>> user application read its value by a getsockopt()
>=20
> I think IP_RECVTTL would work for that idea.

Yes, if it was extented to TCP somehow.

Given this is an IP level option, check could be done at IP level, so t=
hat other protocols
can use it too ?
