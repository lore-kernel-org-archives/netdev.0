From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next 0/4] tunnels: harmonize skb scrubbing
	during encapsulation/decapsulation
Date: Wed, 28 Aug 2013 17:20:06 +0200
Message-ID: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

We talk recently about harmonizing tunnels so they behave consistently wrt. SKB
orphaning, cleaning netfilter state, etc.
The goal of this serie is to achieve this.

Note that I only made some basic tests with ipip, sit and ip6_tunnels modules.

 drivers/net/vxlan.c         |  4 ++--
 include/linux/skbuff.h      |  2 +-
 include/net/dst.h           | 12 +++++++-----
 include/net/ip6_tunnel.h    |  1 -
 include/net/ip_tunnels.h    |  5 ++---
 net/core/dev.c              |  2 +-
 net/core/skbuff.c           | 19 ++++++++++++-------
 net/ipv4/ip_tunnel.c        | 12 ++++--------
 net/ipv4/ip_tunnel_core.c   | 10 ++++------
 net/ipv4/ipmr.c             |  3 +--
 net/ipv6/ip6_gre.c          |  9 +++------
 net/ipv6/ip6_tunnel.c       | 11 ++---------
 net/ipv6/ip6mr.c            |  3 +--
 net/ipv6/sit.c              | 13 +++----------
 net/openvswitch/vport-gre.c |  4 ++--
 15 files changed, 45 insertions(+), 65 deletions(-)

Comments are welcome.

Regards,
Nicolas
