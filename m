From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/10] tty_io: export tty_class
Date: Mon,  1 Jun 2009 18:54:49 +0400
Message-ID: <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1243868091-5315-8-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently tty_class in a public variable in the tty_io.c
Export it to the modules to allow some usefull tricks.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 drivers/char/tty_io.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 66b99a2..4b12d03 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2809,6 +2809,7 @@ int tty_put_char(struct tty_struct *tty, unsigned char ch)
 EXPORT_SYMBOL_GPL(tty_put_char);
 
 struct class *tty_class;
+EXPORT_SYMBOL(tty_class);
 
 /**
  *	tty_register_device - register a tty device
-- 
1.6.2.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
