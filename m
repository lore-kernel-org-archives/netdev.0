From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6 -stable] netfilter/ipvs patches
Date: Fri, 26 Sep 2014 13:43:38 +0200
Message-ID: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This patchset for -stable contains:

1) Fix a crash in IPVS when exitting from netns. This applies cleanly
   starting 3.2.

2) Perform garbage collection from process context in hashlimit,
   otherwise this match can hold the cpu for 500ms with large tables.
   Patch applies to 3.14 and 3.16.

3) Maintain all DSCP and ECN bits for ipv6 tun forwarding in ipvs.
   Patch applies starting 3.4.

4) The cgroup match rejects the id 0 for no good reason and Samsumg
   people needs this to get cgroup match working in previous kernels.
   This one-liner applies starting 3.14.

5) Fix wrong family in hook registration in ipvs, according to my
   scripts, this patch applies cleanly starting 3.10.

6) Fix crash in nf_tables when updating unset chain counters.
   Patch applies to 3.16 only.

I'm sending this batch for -stable submission to netdev in the way I
interpreted from Documentation/networking/netdev-FAQ.txt.

Every patch contains the upstream commit and the tag that indicates
the kernel version as specified by the tag:

Cc: <stable@vger.kernel.org> # x.y.x

Which is the tag I've been using in -stable submissions so far.

Let me know if the way I made is fine with you. Alternatively, I can
make upcoming submissions for -stable in a better way. I can also submit
netfilter/ipvs patches myself, including you, the netdev and the stable
lists in the CC, so you can ack this if you consider they are OK and
people can follow track of what is submitted to -stable from my side.

Thanks!
