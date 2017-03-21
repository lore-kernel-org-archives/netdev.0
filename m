From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH v2 0/2] netfilter: Compress return logic
Date: Tue, 21 Mar 2017 19:00:06 +0530
Message-ID: <1490103008-665-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com,
        wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series Simplify function returns by merging
assignment and return into one command line.

v2:
  -Change the subject of cover patch

simran singhal (2):
  netfilter: ipset: Compress return logic
  netfilter: ipvs: Compress return logic

 net/netfilter/ipset/ip_set_list_set.c | 5 +----
 net/netfilter/ipvs/ip_vs_ftp.c        | 5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

-- 
2.7.4
