From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET 0/16] More gnet_stats conversions
Date: Thu, 21 Oct 2004 14:32:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patchset contains requeues statistics, TLV type max cleanups, and
more conversions to the new generic statistic interface.

It converts all qdiscs to dump their xstats via gnet_stats_copy_app and
converts all class statistics in classful qdiscs to the new API.

The following patches must be applied as a group to not break
anything: 7-9, 10-12, 13-15. All other patches should keep the tree
in a working state. Like the previous qdisc changes, full backward
compatibility is given and all existing applications will continue
to work.

All patches except patch 16 have been tested for 1.5 weeks. The
ATM patch was modified today and only compile tested.

I will provide iproute2 patches for this soon.

Cheers.
