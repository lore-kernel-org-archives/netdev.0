From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3] NET: Generic network statistics/estimator
Date: Sun, 3 Oct 2004 23:31:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003213124.GG14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patchset introduces generic network statistics for netlink
users. It uses nested TLV which prevents further compatibility problems
when introducing new statistics. Backward compatibility to existing
TLV types TCA_STATS and TCA_XSTATS is ensured but can be easly removed
once it is no longer needed. Therefore prior users of struct tc_stats can
be converted to this API and existing userspace applications will not notice
a difference while converted applications can use the new extendable
statistic interface.
