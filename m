From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [bk patches] net driver updates
Date: Sat, 23 Aug 2003 15:42:31 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030823154231.A11381@electric-eye.fr.zoreil.com>
References: <20030817183137.GA18521@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030817183137.GA18521@gtf.org>; from jgarzik@pobox.com on Sun, Aug 17, 2003 at 02:31:37PM -0400
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[net-drivers-2.6 update]
>  drivers/net/sis190.c              | 2094 +++++++++++++++++++++++++++++---------


synchronize_irq() requires an argument when built with CONFIG_SMP.


 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/sis190.c~synchronize_irq-missing-arg-sis190 drivers/net/sis190.c
--- linux-2.6.0-test4/drivers/net/sis190.c~synchronize_irq-missing-arg-sis190	Sat Aug 23 15:37:35 2003
+++ linux-2.6.0-test4-fr/drivers/net/sis190.c	Sat Aug 23 15:37:35 2003
@@ -1111,7 +1111,7 @@ SiS190_close(struct net_device *dev)
 
 	spin_unlock_irq(&tp->lock);
 
-	synchronize_irq();
+	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
 	SiS190_tx_clear(tp);

_
