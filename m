From: Jakub Bogusz <qboosh@pld-linux.org>
Subject: 2.6.8.1 - unresolved xfrm symbols in ip6_tunnel
Date: Tue, 17 Aug 2004 22:30:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817203013.GA31993@satan.blackhosts>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've just got:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.8.1; fi
WARNING: /lib/modules/2.6.8.1/kernel/net/ipv6/ip6_tunnel.ko needs unknown symbol xfrm6_tunnel_register
WARNING: /lib/modules/2.6.8.1/kernel/net/ipv6/ip6_tunnel.ko needs unknown symbol xfrm6_tunnel_deregister

with
CONFIG_IPV6_TUNNEL=m
and no XFRM (it wasn't selected by IPV6_TUNNEL and it's not possible to
select it standalone - XFRM is selected only by some options which
I don't use).

So I think that IPV6_TUNNEL should select or depend on XFRM...
or usage of the above symbols should depend on CONFIG_XFRM ||
CONFIG_XFRM_MODULE?


-- 
Jakub Bogusz    http://cyber.cs.net.pl/~qboosh/
