From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 0/3] af_unix: fix use-after-free
Date: Fri,  2 Oct 2015 20:43:51 +0000 (GMT)
Message-ID: <cover.1443817522.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

These patches are against mainline, I can re-base to net-next, just
let me know.

They have been tested against: https://lkml.org/lkml/2015/9/13/195,
which causes the use-after-free quite quickly and here:
https://lkml.org/lkml/2015/10/2/693.

Thanks,

-Jason


Jason Baron (3):
  unix: fix use-after-free in unix_dgram_poll()
  af_unix: Convert gc_flags to flags
  af_unix: optimize the unix_dgram_recvmsg()

 include/net/af_unix.h |   4 +-
 net/unix/af_unix.c    | 104 ++++++++++++++++++++++++++++++++++++++------------
 net/unix/garbage.c    |  12 +++---
 3 files changed, 88 insertions(+), 32 deletions(-)

-- 
1.8.2.rc2
