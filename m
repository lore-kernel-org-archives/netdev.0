From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] smc91x: fix compilation on SMP
Date: Wed, 26 Aug 2009 12:55:26 +0400
Message-ID: <20090826085526.GA3209@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dongdong.deng@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:56631 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461AbZHZIzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 04:55:53 -0400
Received: by ewy2 with SMTP id 2so1185215ewy.17
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 01:55:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/smc91x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -531,7 +531,7 @@ static inline void  smc_rcv(struct net_device *dev)
 		local_irq_restore(flags);				\
 	__ret;								\
 })
-#define smc_special_lock(lock, flags)		spin_lock_irq(lock, flags)
+#define smc_special_lock(lock, flags)		spin_lock_irqsave(lock, flags)
 #define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
 #else
 #define smc_special_trylock(lock, flags)	(1)
