From: kaber@trash.net
Subject: [PATCH 0/2] netfilter: netfilter fixes
Date: Mon, 31 May 2010 18:14:45 +0200
Message-ID: <1275322487-19026-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the following two patches fix two problems with the recent introduction of
a seperately allocated jumpstack for xtables rulesets:

- a memory leak when registering new tables, from Xiaotian Feng

- performance degradation caused by not using per-CPU allocations
  for the jumpstack, from Eric

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!
