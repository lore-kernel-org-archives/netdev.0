From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/02: xt_osf: fix xt_osf_remove_callback() return value
Date: Thu, 19 Nov 2009 15:59:03 +0100 (MET)
Message-ID: <20091119145903.18633.79066.sendpatchset@x2.localnet>
References: <20091119145902.18633.28666.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091119145902.18633.28666.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1c622ae67bfc729891f5cd80795b15b87e6ac471
Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Fri Nov 13 09:31:35 2009 +0100

    netfilter: xt_osf: fix xt_osf_remove_callback() return value
    
    Return a negative error value.
    
    Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 63e1905..4d1a41b 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -118,7 +118,7 @@ static int xt_osf_remove_callback(struct sock *ctnl, struct sk_buff *skb,
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *sf;
-	int err = ENOENT;
+	int err = -ENOENT;
 
 	if (!osf_attrs[OSF_ATTR_FINGER])
 		return -EINVAL;
