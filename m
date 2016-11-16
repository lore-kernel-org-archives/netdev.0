From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] debugfs: improve formatting of debugfs_real_fops()
Date: Wed, 16 Nov 2016 00:47:28 +0000
Message-ID: <1479257248-10089-1-git-send-email-jakub.kicinski@netronome.com>
References: <1478798629-22318-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38022 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbcKPArv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:47:51 -0500
Received: by mail-wm0-f54.google.com with SMTP id f82so37145236wmf.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:47:51 -0800 (PST)
In-Reply-To: <1478798629-22318-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Type of debugfs_real_fops() is longer than parameters and
the name, so there is no way to break the declaration nicely.
We have to go over 80 characters.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
Sorry, I forgot to include the target tree in the tag, resending.
This is fixup for a patch which is sitting in net-next.

 include/linux/debugfs.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index bf1907d96097..374c6c67e6c0 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -52,8 +52,7 @@ struct debugfs_regset32 {
  * Must only be called under the protection established by
  * debugfs_use_file_start().
  */
-static inline const struct file_operations *
-debugfs_real_fops(const struct file *filp)
+static inline const struct file_operations *debugfs_real_fops(const struct file *filp)
 	__must_hold(&debugfs_srcu)
 {
 	/*
-- 
1.9.1
