From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxa168: close race between napi and irq activation
Date: Fri, 05 Dec 2014 21:34:02 -0800 (PST)
Message-ID: <20141205.213402.629192734867363303.davem@davemloft.net>
References: <1417344576-4940-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, paul.gortmaker@windriver.com,
	w-lkml@lebenslange-mailadresse.de, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaLFF3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:29:33 -0500
In-Reply-To: <1417344576-4940-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sun, 30 Nov 2014 11:49:36 +0100

> In pxa168_eth_open() the irqs are enabled before napi. This opens a tiny time
> window in which the irq handler is processed, disables irqs but then is not able
> to schedule the not yet activated napi, leaving irqs disabled forever (since
> irqs are reenabled in napi poll function).
> Fix this race by activating napi before irqs are activated.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.
