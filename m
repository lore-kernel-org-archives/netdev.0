From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 0/2] net: sched: make it possible to unhide default qdiscs
Date: Sat, 25 Feb 2017 22:29:01 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1702252220000.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a followup to a patchset submitted back in October 2016

	http://lkml.kernel.org/r/alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm

that aimed at making the qdisc hierarchy more transparent and unhide the 
default qdiscs in the dump by default. After some discussion, it turned 
out that the most viable way to go would be to introduce a new netlink 
attribute for this, and let the userspace chose whether it wants to see 
the whole hierarchy dump

	http://lkml.kernel.org/r/20161021.105935.1907696543877061916.davem@davemloft.net

This is implemented by this patchset. First patch adds the new 
TCA_DUMP_INVISIBLE netlink attribute and its handling in the kernel, the 
second one adds the iproute2 counterpart.

-- 
Jiri Kosina
SUSE Labs
