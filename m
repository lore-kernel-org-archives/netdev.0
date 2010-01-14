From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 14 Jan 2010 14:14:32 +0100
Message-ID: <4B4F18B8.8060708@gmail.com>
References: <873a29eywq.fsf@basil.nowhere.org>	<20100114.030454.16178889.davem@davemloft.net>	<20100114112216.GK12241@basil.fritz.box> <20100114.032739.217960336.davem@davemloft.net> <4B4F1044.8080500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: William Allen Simpson <william.allen.simpson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B4F1044.8080500-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 14/01/2010 13:38, William Allen Simpson a =E9crit :
> David Miller wrote:
>> The idea is that the min_ttl is set very high, so that
>> you'll only accept packets from hosts that started with
>> a ttl of 255 and are within a hop or two from you.  (therefore
>> you'd set min_ttl to 254 or 253, something like that)
>>
> That's not a particularly good idea:
>=20
> http://www.iana.org/assignments/ip-parameters
>=20
> IP TIME TO LIVE PARAMETER
>=20
> The current recommended default time to live (TTL) for the Internet
> Protocol (IP) is 64 [RFC791, RFC1122].
>=20
> =3D=3D=3D
>=20
> It always bugs me that things get incorrectly labeled "security", yet
> cannot secure anything.
>=20
> Security requires a secret.
>=20
> Various folks tried all kinds of games with TTL for BGP, but the only
> thing that _actually_ provided security was MD5 authentication.

Nobody forces you to use RFC 5082, I never had.

But if you use it, better read it before, and not use default ttl of 64=
 on
devices wanting to connect to your host.

Note this TTL Security mechanism is not replacing MD5 protection

   The Generalized TTL Security Mechanism (GTSM) is designed to protect
   a router's IP-based control plane from CPU-utilization based attacks=
=2E
   In particular, while cryptographic techniques can protect the router=
-
   based infrastructure (e.g., BGP [RFC4271], [RFC4272]) from a wide
   variety of attacks, many attacks based on CPU overload can be
   prevented by the simple mechanism described in this document.  Note
   that the same technique protects against other scarce-resource
   attacks involving a router's CPU, such as attacks against processor-
   line card bandwidth.


Its only a potential protection against CPU overload.
