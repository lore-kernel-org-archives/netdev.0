From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: pktgen: Call destroy_hrtimer_on_stack()
Date: Tue, 31 May 2016 11:44:22 -0700 (PDT)
Message-ID: <20160531.114422.1427985190775382286.davem@davemloft.net>
References: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
	<1464308466-16525-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbcEaSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:44:24 -0400
In-Reply-To: <1464308466-16525-2-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 26 May 2016 17:21:06 -0700

> If CONFIG_DEBUG_OBJECTS_TIMERS=y, hrtimer_init_on_stack() requires
> a matching call to destroy_hrtimer_on_stack() to clean up timer
> debug objects.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
