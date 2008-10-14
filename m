From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Distributed storage release.
Date: Wed, 15 Oct 2008 03:57:02 +0400
Message-ID: <20081014235702.GA24064@2ka.mipt.ru>
References: <20081013172038.GA18762@2ka.mipt.ru> <20081014232350.GA27915@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081014232350.GA27915@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And to make everyone happy, here is couple of whitespace cleanups.
Everyone happy? I hope so. Now world is round again and there is no war.

commit b2be28f2f09ea9e06753cb50a2e68b4ca0ab4607
Author: Evgeniy Polyakov johnpol@2ka.mipt.ru
Date:   Wed Oct 15 03:27:02 2008 +0400

    Whitespace cleanups

diff --git a/drivers/block/dst/crypto.c b/drivers/block/dst/crypto.c
index 0408a66..0abff5e 100644
--- a/drivers/block/dst/crypto.c
+++ b/drivers/block/dst/crypto.c
@@ -643,7 +643,7 @@ err_out_exit:
 
 /*
  * Schedule crypto processing for given transaction.
- */ 
+ */
 int dst_trans_crypto(struct dst_trans *t)
 {
 	struct dst_node *n = t->n;
diff --git a/drivers/block/dst/dcore.c b/drivers/block/dst/dcore.c
index 039d59b..7f35ae4 100644
--- a/drivers/block/dst/dcore.c
+++ b/drivers/block/dst/dcore.c
@@ -795,7 +795,6 @@ static int dst_start_node(struct dst_node *n, struct dst_ctl *ctl,
 	return 0;
 }
 
-
 typedef int (*dst_command_func)(struct dst_node *n, struct dst_ctl *ctl,
 		void *data, unsigned int size);
 
@@ -823,7 +822,6 @@ static void cn_dst_callback(void *data)
 	struct dst_node *n = NULL, *tmp;
 	unsigned int hash;
 
-
 	if (msg->len < sizeof(struct dst_ctl)) {
 		err = -EBADMSG;
 		goto out;
diff --git a/drivers/block/dst/export.c b/drivers/block/dst/export.c
index 5de330e..b8787fe 100644
--- a/drivers/block/dst/export.c
+++ b/drivers/block/dst/export.c
@@ -271,13 +271,13 @@ static void dst_state_cleanup_export(struct dst_state *st)
 
 			if (p)
 				bio_put(p->bio);
-			
+
 			dprintk("%s: st: %p, refcnt: %d, list_empty: %d, p: %p.\n",
 				__func__, st, atomic_read(&st->refcnt),
 				list_empty(&st->request_list), p);
 		}
 	}
-	
+
 	dst_state_put(st);
 }
 
@@ -327,7 +327,7 @@ static int dst_accept(void *init_data, void *schedule_data)
 	}
 
 	dprintk("%s: freeing listening socket st: %p.\n", __func__, main);
-	
+
 	dst_state_lock(main);
 	dst_poll_exit(main);
 	dst_state_socket_release(main);
diff --git a/drivers/block/dst/state.c b/drivers/block/dst/state.c
index e07036b..c0ad522 100644
--- a/drivers/block/dst/state.c
+++ b/drivers/block/dst/state.c
@@ -809,7 +809,7 @@ int dst_trans_send(struct dst_trans *t)
 	struct bio *bio = t->bio;
 
 	dst_convert_cmd(&t->cmd);
-	
+
 	dst_state_lock(st);
 	if (!st->socket) {
 		err = dst_state_init_connected(st);
@@ -828,7 +828,7 @@ int dst_trans_send(struct dst_trans *t)
 
 	dst_state_unlock(st);
 	return 0;
-	
+
 err_out_reset:
 	dst_state_reset_nolock(st);
 err_out_unlock:
diff --git a/drivers/block/dst/thread_pool.c b/drivers/block/dst/thread_pool.c
index e0c1026..464139e 100644
--- a/drivers/block/dst/thread_pool.c
+++ b/drivers/block/dst/thread_pool.c
@@ -42,7 +42,7 @@ struct thread_pool_worker
 	int			has_data;
 	int			need_exit;
 	unsigned int		id;
-	
+
 	wait_queue_head_t	wait;
 
 	void			*private;
@@ -170,7 +170,7 @@ void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id)
 		}
 	}
 	mutex_unlock(&p->thread_lock);
-	
+
 	if (found)
 		thread_pool_exit_worker(w);
 }


-- 
	Evgeniy Polyakov
