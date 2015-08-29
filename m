From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Sat, 29 Aug 2015 13:46:28 -0700 (PDT)
Message-ID: <20150829.134628.1013990034021542524.davem@davemloft.net>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
	<20150829.131429.360433621593751136.davem@davemloft.net>
	<20150829223115.523553db@tyr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150829223115.523553db@tyr>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Peter N=F8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Date: Sat, 29 Aug 2015 22:31:15 +0200

> On Sat, 29 Aug 2015 13:14:29 -0700 (PDT)
> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>=20
>> From: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
>> Date: Fri, 28 Aug 2015 22:00:47 +0200
>>=20
>> > When the routing cache was removed in 3.6, the IPv4 multipath
>> > algorithm changed from more or less being destination-based into
>> > being quasi-random per-packet scheduling. This increases the risk
>> > of out-of-order packets and makes it impossible to use multipath
>> > together with anycast services.
>>=20
>> Don't even try to be fancy.
>>=20
>> Simply kill the round-robin stuff off completely, and make hash base=
d
>> routing the one and only mode, no special configuration stuff
>> necessary.
>=20
> I like the sound of that! Just to be clear - are you telling me to
> stick with L3 and skip the L4 part?

=46or now it seems best to just do L3 and make ipv4 and ipv6 behave the
same.
