From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: r6040: add in missing white space in error message
 text
Date: Mon, 12 Sep 2016 16:04:01 +0300
Message-ID: <3167d502-bbcc-34db-02d6-8b95ff0a294e@cogentembedded.com>
References: <20160912120857.31600-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160912120857.31600-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/12/2016 3:08 PM, Colin King wrote:

> From: Colin Ian King <colin.king@canonical.com>
>
> A couple of dev_err messages span two lines and the literal
> string is missing a white space between words. Add the white
> space.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/rdc/r6040.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
> index cb29ee2..5dc655b 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -1062,13 +1062,13 @@ static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	/* this should always be supported */
>  	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
>  	if (err) {
> -		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
> +		dev_err(&pdev->dev, "32-bit PCI DMA addresses "
>  				"not supported by the card\n");
>  		goto err_out_disable_dev;
>  	}
>  	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
>  	if (err) {
> -		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
> +		dev_err(&pdev->dev, "32-bit PCI DMA addresses "
>  				"not supported by the card\n");
>  		goto err_out_disable_dev;
>  	}

    The message strings simply shouldn't be broken up, and checkpatch.pl knows 
about that.

MBR, Sergei
