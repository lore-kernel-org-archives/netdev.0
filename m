From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET 0/11] PKT_SCHED: overall net/pkt_cls.h and net/pkt_sched.h cleanup
Date: Wed, 27 Oct 2004 00:21:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patchset attempts to clean up the mess in net/pkt_sched.h
and net/pkt_cls.h grown over the last years.

It introduces net/sch_generic.h containing all generic
sch/cls bits and act_api.h containing pubic action/policer
bits.

The current architecture which is basically to have
net/pkt_sched.h include net/pkt_cls.h and everyone just
including net/pkt_sched.h makes it impossible to add
any generic classifer bits into pkt_cls.h and acted
just like if we had put it into one big file.

Tested for nearly a week with various combinations of
action/policer configurations.

See patch descriptions for more details.

Dave, Jamal: The only difference to the previous patchset is that
it doesn't touch qdisc_tree_lock and qdisc_lookup anymore
but let cls_api.c include net/pkt_sched.h which makes more sense.
I splitted up the patches a bit more to improve readability for the
review.
