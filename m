From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] rose_add_loopback_node: propagate -E
Date: Sun, 3 Dec 2006 00:33:39 +0300
Message-ID: <20061202213339.GB2714@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:58128 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1162502AbWLBVdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 16:33:40 -0500
Received: by nf-out-0910.google.com with SMTP id o25so3932293nfa
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 13:33:39 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Binderman's icc logs:
net/rose/rose_route.c(399): remark #593: variable "err" was set but never used

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/rose/rose_route.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -396,7 +396,7 @@ int rose_add_loopback_neigh(void)
 int rose_add_loopback_node(rose_address *address)
 {
 	struct rose_node *rose_node;
-	unsigned int err = 0;
+	int err = 0;
 
 	spin_lock_bh(&rose_node_list_lock);
 
@@ -432,7 +432,7 @@ int rose_add_loopback_node(rose_address 
 out:
 	spin_unlock_bh(&rose_node_list_lock);
 
-	return 0;
+	return err;
 }
 
 /*

