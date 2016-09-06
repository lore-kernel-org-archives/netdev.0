From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: ixp46x: remove NO_IRQ handling
Date: Tue, 6 Sep 2016 18:39:10 +0200
Message-ID: <20160906163910.GC7012@localhost.localdomain>
References: <20160906142849.3297250-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Kefeng Wang <wangkefeng.wang@huawei.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160906142849.3297250-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 06, 2016 at 04:28:30PM +0200, Arnd Bergmann wrote:
> gpio_to_irq does not return NO_IRQ but instead returns a negative
> error code on failure. Returning NO_IRQ from the function has no
> negative effects as we only compare the result to the expected
> interrupt number, but it's better to return a proper failure
> code for consistency, and we should remove NO_IRQ from the kernel
> entirely.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Richard Cochran <richardcochran@gmail.com>
