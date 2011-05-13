From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next-2.6] net: ipv4: add ping_group_range documentation
Date: Sat, 14 May 2011 00:22:13 +0200
Message-ID: <1305325333.3120.36.camel@edumazet-laptop>
References: <20110510.121550.112583080.davem@davemloft.net>
	 <20110513200100.GA3875@albatros>  <m2wrhuxp8c.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	peak-8SWXkBwqxoT9tFMPJ9EooEJFmxxWawaa@public.gmane.org, kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	dan.j.rosenberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, eugene-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nelhage-SEpxePOmGhdBDgjK7y7TUQ@public.gmane.org,
	kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m2wrhuxp8c.fsf-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 mai 2011 =C3=A0 14:30 -0700, Andi Kleen a =C3=A9crit :
> Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> writes:
>=20
> > This patch adds IPPROTO_ICMP socket kind.  It makes it possible to =
send
> > ICMP_ECHO messages and receive the corresponding ICMP_ECHOREPLY mes=
sages
> > without any special privileges.  In other words, the patch makes it
> > possible to implement setuid-less and CAP_NET_RAW-less /bin/ping.  =
In
> > order not to increase the kernel's attack surface, the new function=
ality
> > is disabled by default, but is enabled at bootup by supporting Linu=
x
> > distributions, optionally with restriction to a group or a group ra=
nge
> > (see below).
>=20
> You'll need to do a manpage patch too. Otherwise noone will know how =
to use
> it.

Yes probably...

It would be nice to copy part of changelog in=20
Documentation/networking/ip-sysctl.txt


socket(2) is restricted to the group range specified in
"/proc/sys/net/ipv4/ping_group_range".  It is "1 0" by default, meaning
that nobody (not even root) may create ping sockets.  Setting it to "10=
0
100" would grant permissions to the single group (to either make
/sbin/ping g+s and owned by this group or to grant permissions to the
"netadmins" group), "0 4294967295" would enable it for the world, "100
4294967295" would enable it for the users, but not daemons.


Too late here, time for sleep...


--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
