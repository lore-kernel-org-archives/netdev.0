From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/5] PKT_SCHED: Convert Qdiscs to use generic network
 statistics/estimator
Date: Tue, 19 Oct 2004 18:19:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019181918.358ee531.davem@davemloft.net>
References: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041007010146.GA18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004 03:01:46 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> This patchset converts Qdiscs to use the generic network
> statistics/estimator. A new TLV type TCA_STATS2 is introduced
> carrying the new statistics while the old TLV type TCA_STATS
> is still provided for backward compatibility.
> 
> Patch 1: Replace tc_stats with new gnet_stats in struct Qdisc
> Patch 2: Use gnet_stats API to copy statistics into netlink message
> Patch 3: Introduce gen_replace_estimator
> Patch 4: Use generic rate estimator
> Patch 5: Qdisc are not supposed to dump TCA_STATS themselves

All 5 patches applied, thanks Thomas.
