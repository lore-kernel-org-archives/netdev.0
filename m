From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next 0/2] fixes for recent nf_compact hooks
Date: Mon, 26 Sep 2016 12:24:29 -0400
Message-ID: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two possible error conditions were caught during an extended testing
session, and by a build robot.  These patches fix the two issues (a
missing handler when config is changed, and a potential NULL
dereference).

Aaron Conole (2):
  netfilter: Fix potential null pointer dereference
  nf_set_hooks_head: acommodate different kconfig

 net/netfilter/core.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

-- 
2.5.5

