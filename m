From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [NFS] [PATCH 56/59] net/sunrpc: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:43 -0800
Message-ID: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe__29991.7693868794$1195523857$gmane$org@perches.com>
References: 1234567 <1195523627-15389-1-git-send-email-joe@perches.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Networking Team <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, nfs-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1195523627-15389-13-git-send-email-joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Message-Id: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org is being discontinued.
Please subscribe to linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

-
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
