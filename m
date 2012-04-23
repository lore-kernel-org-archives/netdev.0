From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] net/at91_ether: use gpio_to_irq for phy IRQ line
Date: Mon, 23 Apr 2012 11:35:00 +0200
Message-ID: <20120423093500.GG9142@game.jcrosoft.org>
References: <1335173852-582-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, avictor.za@gmail.com,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335173852-582-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11:37 Mon 23 Apr     , Nicolas Ferre wrote:
> Use the gpio_to_irq() function to retrieve the phy IRQ line
> from the GPIO pin specification.
> This fix is needed now that we have moved to irqdomains on AT91.
> 
> Reported-by: Jamie Iles <jamie@jamieiles.com>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Andrew Victor <avictor.za@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/cadence/at91_ether.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
I send a send a patch to cleanup the at91_ether please rebase over it

this patch is here  for a while

Best Regards,
J.
