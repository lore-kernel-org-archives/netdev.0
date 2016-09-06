From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ptp: ixp46x: remove NO_IRQ handling
Date: Tue, 06 Sep 2016 16:57:28 -0700 (PDT)
Message-ID: <20160906.165728.124928924200975859.davem@davemloft.net>
References: <20160906192053.1061021-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906192053.1061021-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  6 Sep 2016 21:20:36 +0200

> gpio_to_irq does not return NO_IRQ but instead returns a negative
> error code on failure. Returning NO_IRQ from the function has no
> negative effects as we only compare the result to the expected
> interrupt number, but it's better to return a proper failure
> code for consistency, and we should remove NO_IRQ from the kernel
> entirely.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied to net-next, thanks.
