From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: [RFC] ipv6_get_ifaddr(), alway called with strict =1
Date: Mon, 16 Dec 2013 12:07:32 -0800 (PST)
Message-ID: <1387224452.59094.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm40.bullet.mail.ne1.yahoo.com ([98.138.229.33]:25805 "HELO
	nm40.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752003Ab3LPUKa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 15:10:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Doubtless, this argument is no more usefull.

Any reason to keep it ?

=46ran=E7ois-Xavier

---

include/net/addrconf.h:struct inet6_ifaddr *ipv6_get_ifaddr(struct net =
*net,
include/net/addrconf.h-                              const struct in6_a=
ddr *addr,
include/net/addrconf.h-                              struct net_device =
*dev, int strict);
--
net/ipv6/addrconf.c:struct inet6_ifaddr *ipv6_get_ifaddr(struct net *ne=
t, const struct in6_addr *addr,
net/ipv6/addrconf.c-                                 struct net_device =
*dev, int strict)
net/ipv6/addrconf.c-{
--
net/ipv6/addrconf.c:            ifp =3D ipv6_get_ifaddr(net, &addr, dev=
, 1);
--
net/ipv6/addrconf.c:    ifa =3D ipv6_get_ifaddr(net, pfx, dev, 1);
--
net/ipv6/addrconf.c:    ifa =3D ipv6_get_ifaddr(net, addr, dev, 1);
--
net/ipv6/ip6_output.c:          ifp =3D ipv6_get_ifaddr(net, &fl6->sadd=
r,
net/ipv6/ip6_output.c-                                (*dst)->dev, 1);
--
net/ipv6/ndisc.c:       ifp =3D ipv6_get_ifaddr(dev_net(dev), solicited=
_addr, dev, 1);
--
net/ipv6/ndisc.c:               struct inet6_ifaddr *ifp =3D ipv6_get_i=
faddr(dev_net(dev), saddr,
net/ipv6/ndisc.c-                                                      =
    dev, 1);
--
net/ipv6/ndisc.c:       ifp =3D ipv6_get_ifaddr(dev_net(dev), &msg->tar=
get, dev, 1);
--
net/ipv6/ndisc.c:       ifp =3D ipv6_get_ifaddr(dev_net(dev), &msg->tar=
get, dev, 1);
