From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: connecting ipv6 nodes throu' ipv4 network ....
Date: Thu, 20 Feb 2003 12:52:55 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0302201249190.6510@dns.toxicfilms.tv>
References: <20030220104719.835.qmail@webmail32.rediffmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: santosh kumar gowda <ipv6_san@rediffmail.com>
In-Reply-To: <20030220104719.835.qmail@webmail32.rediffmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> IPv6 addr of machine-1 is 3ff3:1234::1
> IPv6 addr of machine-2 is 3ff3:1234::2
> My LAN is based on IPv4.
> To make these IPv6-hosts to communicate on the LAN, what
> configuration do i need to make ???

Well, as in ipv4 the hosts need an address and routing:
machine-1:
# ip addr add 3ff3:1234::1 dev eth0
# ip route add 3ffe:1234/mask dev eth0

machine-2:
# ip addr add 3ff3:1234::1 dev eth0
# ip route add 3ff3:1234/mask dev eth0

If you have a route to the ip6 world, then add to them:
# ip route add 2001::/3 via (your:ip6:router:address) dev eth0

> I tried connecting only these two machines using a cross cable and
> sending IPv6 packets. But it failed. Is it correct to do so ???
Should work, maybe the cables are bad?

Regards,
Maciej
