From: Richard Weinberger <richard@nod.at>
Subject: [PATCH v4] Merge ipt_LOG and ip6t_LOG, add ring bufffer support
Date: Thu,  9 Feb 2012 22:54:47 +0100
Message-ID: <1328824493-4136-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jengelh@medozas.de, rostedt@goodmis.org,
	pablo@netfilter.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set merges ipt_LOG and ip6t_LOG and adds ring buffer support
to xt_LOG.

Using "--ring" a user can create LOG rules which log messages into
one or more ring buffers.
Each ring buffer is represented as pipe-like file in
/proc/net/netfilter/xt_LOG_ring/.

Ring buffer support can be enabled/disabled using
CONFIG_NETFILTER_XT_TARGET_LOG_RING.

Changes since v1:
 - Merged ipt_LOG and ip6t_LOG
 - Implemented ring buffer support as part of xt_LOG.

Changes since v2:
 - Fixed struct xt_log_info_v1's data layout
 - Removed the sizeof(void *) hack
 - Replaced BUG() by WARN_ON_ONCE()

Changes since v3:
 - Merged xt_LOG_core.c and xt_LOG_ring.c into xt_LOG.c
 - Made checkpatch.pl happy

All patches can also be found at:
git://git.kernel.org/pub/scm/linux/kernel/git/rw/misc.git xt_LOG
git://git.kernel.org/pub/scm/linux/kernel/git/rw/iptables.git xt_LOG

[PATCH 1/2] iptables: Merge libip6t_LOG and libipt_LOG into
[PATCH 2/2] iptables: xt_LOG: Add ring buffer support

[PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
[PATCH 2/4] ring_buffer: Export for_each_buffer_cpu()
[PATCH 3/4] xt_log: Make printk() in sb_close() optional
[PATCH 4/4] Netfilter: xt_LOG: Implement ring buffer support
