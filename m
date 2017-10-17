From: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/4] NFSD: make cache_detail structures const
Date: Tue, 17 Oct 2017 18:14:25 +0200
Message-ID: <1508256866-12798-4-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: julia.lawall-L2FTfq7BK8M@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
        jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make these const as they are only getting passed to the function
cache_create_net having the argument as const.

Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/nfsd/export.c    | 4 ++--
 fs/nfsd/nfs4idmap.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 3bc08c3..06bb39c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -231,7 +231,7 @@ static struct cache_head *expkey_alloc(void)
 		return NULL;
 }
 
-static struct cache_detail svc_expkey_cache_template = {
+static const struct cache_detail svc_expkey_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPKEY_HASHMAX,
 	.name		= "nfsd.fh",
@@ -747,7 +747,7 @@ static struct cache_head *svc_export_alloc(void)
 		return NULL;
 }
 
-static struct cache_detail svc_export_cache_template = {
+static const struct cache_detail svc_export_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPORT_HASHMAX,
 	.name		= "nfsd.export",
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 6b9b6cc..a5bb765 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -178,7 +178,7 @@ struct ent {
 static struct ent *idtoname_update(struct cache_detail *, struct ent *,
 				   struct ent *);
 
-static struct cache_detail idtoname_cache_template = {
+static const struct cache_detail idtoname_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.idtoname",
@@ -341,7 +341,7 @@ static struct ent *nametoid_update(struct cache_detail *, struct ent *,
 				   struct ent *);
 static int         nametoid_parse(struct cache_detail *, char *, int);
 
-static struct cache_detail nametoid_cache_template = {
+static const struct cache_detail nametoid_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.nametoid",
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
