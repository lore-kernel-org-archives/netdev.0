From: Joe Perches <joe@perches.com>
Subject: [PATCH 56/59] net/sunrpc: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:43 -0800
Message-ID: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe__26163.5262905203$1195524719$gmane$org@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
 <1195523627-15389-9-git-send-email-joe@perches.com>
 <1195523627-15389-10-git-send-email-joe@perches.com>
 <1195523627-15389-11-git-send-email-joe@perches.com>
 <1195523627-15389-12-git-send-email-joe@perches.com>
 <1195523627-15389-13-git-send-email-joe@perches.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Networking Team <netdev@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760413AbXKTCL0@vger.kernel.org>
In-Reply-To: <1195523627-15389-13-git-send-email-joe@perches.com>
Message-Id: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 53995af..22906b8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -967,7 +967,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
-		dprintk("RPC: %5u gss_validate: gss_verify_mic returned"
+		dprintk("RPC: %5u gss_validate: gss_verify_mic returned "
 				"error 0x%08x\n", task->tk_pid, maj_stat);
 		goto out_bad;
 	}
-- 
1.5.3.5.652.gf192c
