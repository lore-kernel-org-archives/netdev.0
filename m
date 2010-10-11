From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ATM: iphase, remove sleep-inside-atomic
Date: Mon, 11 Oct 2010 11:13:13 -0700 (PDT)
Message-ID: <20101011.111313.59678995.davem@davemloft.net>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
	<1286789218-13976-2-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, chas@cmf.nrl.navy.mil
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47192
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755828Ab0JKSMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 14:12:51 -0400
In-Reply-To: <1286789218-13976-2-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 11 Oct 2010 11:26:57 +0200

> Stanse found that ia_init_one locks a spinlock and inside of that it
> calls ia_start which calls:
> * request_irq
> * tx_init which does kmalloc(GFP_KERNEL)
> 
> Both of them can thus sleep and result in a deadlock. I don't see a
> reason to have a per-device spinlock there which is used only there
> and inited right before the lock location. So remove it completely.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied.
