From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 1/2] cdc_ncm: add the currently processed NDP frame to global driver data
Date: Tue,  2 Jun 2015 11:08:34 +0200
Message-ID: <1433236115-5594-2-git-send-email-mrkiko.rs@gmail.com>
References: <1433236115-5594-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433236115-5594-1-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is useful to split up the cdc_ncm_ndp function later on.
The resulting code will be anyway stateful.

Signed-Off-By: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/usb/cdc_ncm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 7c9b484..9172256 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -100,6 +100,7 @@ struct cdc_ncm_ctx {
 	struct sk_buff *tx_curr_skb;
 	struct sk_buff *tx_rem_skb;
 	__le32 tx_rem_sign;
+	struct usb_cdc_ncm_ndp16 *tx_curr_ndp16;
 
 	spinlock_t mtx;
 	atomic_t stop;
-- 
2.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
