From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5] PKT_SCHED: Convert Qdiscs to use generic network statistics/estimator
Date: Thu, 7 Oct 2004 03:01:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patchset converts Qdiscs to use the generic network
statistics/estimator. A new TLV type TCA_STATS2 is introduced
carrying the new statistics while the old TLV type TCA_STATS
is still provided for backward compatibility.

Patch 1: Replace tc_stats with new gnet_stats in struct Qdisc
Patch 2: Use gnet_stats API to copy statistics into netlink message
Patch 3: Introduce gen_replace_estimator
Patch 4: Use generic rate estimator
Patch 5: Qdisc are not supposed to dump TCA_STATS themselves

I tested these patches for a few days and didn't encounter
any problems. iproute2 is able to read out statistics via
backward compatibility. A slightly patched iproute2 can
read the new statistics.
