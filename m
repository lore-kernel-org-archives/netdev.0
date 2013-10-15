From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 4/5] net: macb: Use devm_request_irq()
Date: Tue, 15 Oct 2013 23:21:08 +0400
Message-ID: <525D95A4.3020706@cogentembedded.com>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com> <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/15/2013 03:58 AM, Soren Brinkmann wrote:

> Use the device managed interface to request the IRQ, simplifying error
> paths.

> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> ---
>   drivers/net/ethernet/cadence/macb.c | 8 +++-----
>   1 file changed, 3 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 436aecc31732..603844b1d483 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1825,7 +1825,8 @@ static int __init macb_probe(struct platform_device *pdev)
>   	}
>
>   	dev->irq = platform_get_irq(pdev, 0);
> -	err = request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
> +	err = devm_request_irq(&pdev->dev, dev->irq, macb_interrupt, 0,
> +			dev->name, dev);

    You should start the continuation line right under &.

WBR, Sergei
