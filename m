From: pablo@netfilter.org
Subject: [PATCH 09/21] netfilter: add missing xt_connlabel.h header in installation
Date: Fri, 25 Jan 2013 14:54:41 +0100
Message-ID: <1359122093-3404-10-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

In (c539f01 netfilter: add connlabel conntrack extension), it
was missing the change to the Kbuild file to install the header
in the system.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/Kbuild |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 8b4bd36..4111577 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -39,6 +39,7 @@ header-y += xt_bpf.h
 header-y += xt_cluster.h
 header-y += xt_comment.h
 header-y += xt_connbytes.h
+header-y += xt_connlabel.h
 header-y += xt_connlimit.h
 header-y += xt_connmark.h
 header-y += xt_conntrack.h
-- 
1.7.10.4

