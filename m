From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND
 flag
Date: Thu, 24 Sep 2015 14:23:13 -0700 (PDT)
Message-ID: <20150924.142313.529174195447744153.davem@davemloft.net>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
	<1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, rjw@rjwysocki.net,
	claudiu.manoil@freescale.com, haokexin@gmail.com,
	netdev@vger.kernel.org
To: sudeep.holla@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071AbbIXVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:23:14 -0400
In-Reply-To: <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudeep Holla <sudeep.holla@arm.com>
Date: Mon, 21 Sep 2015 16:47:09 +0100

> The device is set as wakeup capable using proper wakeup API but the
> driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
> which is incorrect.
> 
> This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
> enable_irq_wake instead.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Cc: Kevin Hao <haokexin@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>

Applied, thanks.
