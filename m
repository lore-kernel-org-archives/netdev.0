From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netconsole support for b44
Date: Tue, 12 Oct 2004 13:09:49 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041012180949.GW5414@waste.org>
References: <416BC26B.6090603@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com,
        linux kernel mailing list <linux-kernel@vger.kernel.org>,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Con Kolivas <kernel@kolivas.org>
Content-Disposition: inline
In-Reply-To: <416BC26B.6090603@kolivas.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 12, 2004 at 09:39:23PM +1000, Con Kolivas wrote:
> This patch adds poll support to the b44 driver to allow netconsole 
> support. Style lifted straight from 8139too.c
> 
> here is the dmesg output with it in place:
> 
> netconsole: device eth0 not up yet, forcing it
> netconsole: carrier detect appears flaky, waiting 10 seconds
> b44: eth0: Link is down.
> b44: eth0: Link is up at 100 Mbps, full duplex.
> b44: eth0: Flow control is on for TX and on for RX.
> netconsole: network logging started
> 
> output confirmed by netcat on other system.
> 
> Signed-off-by: Con Kolivas <kernel@kolivas.org>

+       disable_irq(dev->irq);
+       b44_interrupt (dev->irq, dev, NULL);
+       enable_irq(dev->irq);

Aside from this bizarre whitespace convention and neglecting to cc:
me, looks good.

-- 
Mathematics is the supreme nostalgia of our time.
