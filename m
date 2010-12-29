From: Joe Perches <joe@perches.com>
Subject: Re: dm9000 patch
Date: Wed, 29 Dec 2010 13:16:32 -0800
Message-ID: <1293657392.31071.15.camel@Joe-Laptop>
References: <4D1A5C2A.5050606@gmail.com>
	 <20101229060637.GA31010@jasper.tkos.co.il>	<4D1B33F2.5060600@gmail.com>
	 <20101229180650.GE6067@tarshish>
	 <AANLkTim0+GbddLdkPFoggeCKpU7on7mta0V2mZZLgviE@mail.gmail.com>
	 <4D1BA0D0.1060407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Baruch Siach <baruch@tkos.co.il>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org,
	uClinux development list <uclinux-dev@uclinux.org>
To: Angelo Dureghello <angelo70@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2871 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab0L2VQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 16:16:34 -0500
In-Reply-To: <4D1BA0D0.1060407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-29 at 21:57 +0100, Angelo Dureghello wrote:
> the kernel is a main line kernel. Then yes, i am still using uclinux 
> tree for libc/tools.

Does it still occur if you remove the debug line below?
---
 drivers/net/dm9000.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 2d4c4fc..c774430 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1077,8 +1077,6 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 	unsigned long flags;
 	u8 reg_save;
 
-	dm9000_dbg(db, 3, "entering %s\n", __func__);
-
 	/* A real interrupt coming */
 
 	/* holders of db->lock must always block IRQs */


