From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET 0/8] PKT_SCHED: Use gnet_stats for actions and policer
Date: Wed, 3 Nov 2004 22:58:16 +0100
Message-ID: <20041103215816.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This is the last patchset in my attempt to clean up traffic
control statistics. It converts the action and policer code
to the gnet_stats API.

I decided to not provide backward compatibility for action
statistics and introduce a new TLV type TCA_ACT_STATS for them
in order to get some consistency and be prepared if we ever
introduce statistics to classifiers. This was approved by Jamal.

Shall I mark the old estimator and statistic API as __deprecated
or remove it right away?

Cheers
