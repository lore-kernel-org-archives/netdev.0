From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net] tg3: Avoid null pointer dereference in
 tg3_interrupt in netconsole mode
Date: Mon, 14 Jan 2013 22:09:40 -0500 (EST)
Message-ID: <20130114.220940.967320497069734116.davem@davemloft.net>
References: <1358219460-5993-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912Ab3AODJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 22:09:45 -0500
In-Reply-To: <1358219460-5993-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 14 Jan 2013 19:10:59 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> When netconsole is enabled, logging messages generated during tg3_open
> can result in a null pointer dereference for the uninitialized tg3
> status block. Use the irq_sync flag to disable polling in the early
> stages. irq_sync is cleared when the driver is enabling interrupts after
> all initialization is completed.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
