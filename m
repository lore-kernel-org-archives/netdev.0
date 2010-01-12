From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Mon, 11 Jan 2010 16:27:03 -0800 (PST)
Message-ID: <20100111.162703.24001534.davem@davemloft.net>
References: <20100111082529.3d5cdae3@nehalam>
	<4B4B5A0A.3090600@gmail.com>
	<4B4B5B84.3090409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B4B5B84.3090409-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 11 Jan 2010 18:10:28 +0100

> Le 11/01/2010 18:04, Eric Dumazet a =E9crit :
>> Given this is an IP level option, check could be done at IP level, s=
o that other protocols
>> can use it too ?
>=20
> Oops, this is stupid, we dont have the socket pointer at IP level :)

Right.

But we can later add a helper to place in each protocols receive path,
at the point where it first has a socket to work with.

I'm going to apply Stephen's original patch.

Thanks!
