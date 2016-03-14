From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: Add missing hotplug notifier transition
Date: Mon, 14 Mar 2016 15:22:33 -0400 (EDT)
Message-ID: <20160314.152233.1590281361949645151.davem@davemloft.net>
References: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: anna-maria@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Date: Fri, 11 Mar 2016 10:10:23 +0100

> The mvneta_percpu_notifier() hotplug callback lacks handling of the
> CPU_DOWN_FAILED case. That means, if CPU_DOWN_PREPARE failes, the
> driver is not well configured on the CPU.
> 
> Add handling for CPU_DOWN_FAILED[_FROZEN] hotplug notifier transition
> to setup the driver.
> 
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>

Applied, thanks.
