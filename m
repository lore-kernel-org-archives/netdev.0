From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mvneta: Remove superfluous SMP function call
Date: Tue, 03 May 2016 15:28:06 -0400 (EDT)
Message-ID: <20160503.152806.1985815306043431466.davem@davemloft.net>
References: <1462179771-55875-1-git-send-email-anna-maria@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: anna-maria@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbcECT2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 15:28:09 -0400
In-Reply-To: <1462179771-55875-1-git-send-email-anna-maria@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Date: Mon,  2 May 2016 11:02:51 +0200

> Since commit 3b9d6da67e11 ("cpu/hotplug: Fix rollback during error-out
> in __cpu_disable()") it is ensured that callbacks of CPU_ONLINE and
> CPU_DOWN_PREPARE are processed on the hotplugged CPU. Due to this SMP
> function calls are no longer required.
> 
> Replace smp_call_function_single() with a direct call to
> mvneta_percpu_enable() or mvneta_percpu_disable(). The functions do
> not require to be called with interrupts disabled, therefore the
> smp_call_function_single() calling convention is not preserved.
> 
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>

Applied, thanks.
