From: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/7] o80211s: Export dev_seq_{start,stop,next} symbols.
Date: Mon, 29 Oct 2007 14:44:01 -0700
Message-ID: <4727ddda.27ed720a.2444.6daf@mx.google.com>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the first patch of a series starting mesh wireless support (802.11s) for
wireless network cards with drivers using the mac80211 stack.

It is still in an early stage of development but some functionality (static
forwarding) is quite solid and we would like the code to be integrated in the
kernel the sooner the better. Please point out any section of the code that
could pose a problem towards integration. The patches apply against current
wireless-2.6/everything.

For more information, please visit: http://o11s.org/devel

This patches are being sent just to linux-wireless mailing list. I'm just
sending this one patch also to netdev since it is not wireless specific.

Signed-off-by: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
---
 net/core/dev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8726589..9c005f2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2348,6 +2348,7 @@ void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(dev_seq_start);
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
@@ -2356,11 +2357,13 @@ void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	return v == SEQ_START_TOKEN ?
 		first_net_device(net) : next_net_device((struct net_device *)v);
 }
+EXPORT_SYMBOL_GPL(dev_seq_next);
 
 void dev_seq_stop(struct seq_file *seq, void *v)
 {
 	read_unlock(&dev_base_lock);
 }
+EXPORT_SYMBOL_GPL(dev_seq_stop);
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
-- 
1.5.2.5
