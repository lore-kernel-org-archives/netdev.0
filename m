From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Mon, 9 Apr 2007 23:33:36 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704092332030.22295@yvahk01.tjqt.qr>
References: <20070409212723.31670.27976.stgit@gitlost.site>
 <20070409212841.31670.59366.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:40129 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932074AbXDIVko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 17:40:44 -0400
In-Reply-To: <20070409212841.31670.59366.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


On Apr 9 2007 14:28, Peter P Waskiewicz Jr wrote:
>@@ -3345,6 +3358,7 @@ void free_netdev(struct net_device *dev)
> {
> #ifdef CONFIG_SYSFS
> 	/*  Compatibility with error handling in drivers */
>+	kfree((char *)dev->egress_subqueue);
> 	if (dev->reg_state == NETREG_UNINITIALIZED) {
> 		kfree((char *)dev - dev->padded);
> 		return;
>@@ -3356,6 +3370,7 @@ void free_netdev(struct net_device *dev)
> 	/* will free via device release */
> 	put_device(&dev->dev);
> #else
>+	kfree((char *)dev->egress_subqueue);
> 	kfree((char *)dev - dev->padded);
> #endif
> }

Ahem. Explain that cast.



Jan
-- 
