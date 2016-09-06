From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ptp: ixp46x: remove NO_IRQ handling
Date: Tue, 06 Sep 2016 21:18:50 +0200
Message-ID: <37073907.KMu7rEfE59@wuerfel>
References: <20160906142849.3297250-1-arnd@arndb.de> <20160906163910.GC7012@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Kefeng Wang <wangkefeng.wang@huawei.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906163910.GC7012@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, September 6, 2016 6:39:10 PM CEST Richard Cochran wrote:
> On Tue, Sep 06, 2016 at 04:28:30PM +0200, Arnd Bergmann wrote:
> > gpio_to_irq does not return NO_IRQ but instead returns a negative
> > error code on failure. Returning NO_IRQ from the function has no
> > negative effects as we only compare the result to the expected
> > interrupt number, but it's better to return a proper failure
> > code for consistency, and we should remove NO_IRQ from the kernel
> > entirely.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Thanks!

I just realized that the randconfig builder had not picked up this
one and there was a typo. I'll send a replacement patch with your
Ack added in.

	Arnd
