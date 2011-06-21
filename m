From: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Subject: [PATCH] svcauth_unix.c: quiet sparse noise
Date: Mon, 20 Jun 2011 18:19:12 -0700
Message-ID: <201106201819.12839.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	<neilb-l3A5Bk7waGM@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Like svcauth_unix, the symbol svcauth_null is used external from this
file. Declare it as extern to quiet the following sparse noise:

warning: symbol 'svcauth_null' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

---

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index c8e1021..62e49e2 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -36,6 +36,7 @@ struct unix_domain {
 	/* other stuff later */
 };
 
+extern struct auth_ops svcauth_null;
 extern struct auth_ops svcauth_unix;
 
 static void svcauth_unix_domain_release(struct auth_domain *dom)
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
