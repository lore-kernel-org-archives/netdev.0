From: Wichert Akkerman <wichert@wiggy.net>
Subject: ing_filter debug messages
Date: Thu, 30 Dec 2004 17:06:43 +0100
Message-ID: <20041230160643.GD24603@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After upgrading a machine to (unpatched mainline) 2.6.10 my kernel log
is filled with ing_filter (debug?) messages:

Dec 30 16:24:58 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 16:24:58 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 16:37:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 16:37:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 16:49:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 16:49:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 17:01:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
Dec 30 17:01:08 thunder kernel: ing_filter:  fixed  eth1 out eth1

the messages always come in pairs. eth1 is the externel interface which
has a standard wondershaper configuration attached to it. Relevant bits
of .config are below.

Wichert.


#
# QoS and/or fair queueing
#
CONFIG_NET_SCHED=y
CONFIG_NET_SCH_CLK_JIFFIES=y
# CONFIG_NET_SCH_CLK_GETTIMEOFDAY is not set
# CONFIG_NET_SCH_CLK_CPU is not set
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
# CONFIG_NET_SCH_PRIO is not set
# CONFIG_NET_SCH_RED is not set
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
CONFIG_NET_SCH_TBF=y
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_INGRESS=y
CONFIG_NET_QOS=y
CONFIG_NET_ESTIMATOR=y
CONFIG_NET_CLS=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_PEDIT=y


-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
