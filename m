From: pablo@netfilter.org
Subject: [PATCH 0/3] netfilter fixes for your net tree
Date: Thu,  7 Mar 2013 11:59:59 +0100
Message-ID: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

* Don't generate audit log message if audit is not enabled, from Gao Feng.

* Fix logging formatting for packets dropped by helpers, by Joe Perches.

* Fix a compilation warning in nfnetlink if CONFIG_PROVE_RCU is not set,
  from Paul Bolle.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Gao feng (1):
  netfilter: xt_AUDIT: only generate audit log when audit enabled

Joe Perches (1):
  netfilter: nf_ct_helper: Fix logging for dropped packets

Paul Bolle (1):
  netfilter: nfnetlink: silence warning if CONFIG_PROVE_RCU isn't set

 net/netfilter/nf_conntrack_helper.c |   11 ++++++++++-
 net/netfilter/nfnetlink.c           |    7 +------
 net/netfilter/xt_AUDIT.c            |    3 +++
 3 files changed, 14 insertions(+), 7 deletions(-)

-- 
1.7.10.4

