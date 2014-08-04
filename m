From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 02/19] drivers: atm: fix %d confusingly prefixed with 0x
 in format strings
Date: Mon, 4 Aug 2014 07:16:38 -0400
Message-ID: <20140804071638.32fd85ed@thirdoffive.cmf.nrl.navy.mil>
References: <1407111500-14547-1-git-send-email-hans@hanshq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hans Wennborg <hans@hanshq.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407111500-14547-1-git-send-email-hans@hanshq.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

On Sun,  3 Aug 2014 17:18:20 -0700
Hans Wennborg <hans@hanshq.net> wrote:

> Signed-off-by: Hans Wennborg <hans@hanshq.net>
> ---
>  drivers/atm/eni.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
> index b1955ba..d65975a 100644
> --- a/drivers/atm/eni.c
> +++ b/drivers/atm/eni.c
> @@ -2155,7 +2155,7 @@ static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
>  
>  		if (!tx->send) continue;
>  		if (!--left) {
> -			return sprintf(page,"tx[%d]:    0x%ld-0x%ld "
> +			return sprintf(page, "tx[%d]:    0x%lx-0x%lx "
>  			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n",i,
>  			    (unsigned long) (tx->send - eni_dev->ram),
>  			    tx->send-eni_dev->ram+tx->words*4-1,tx->words*4,
> @@ -2181,7 +2181,7 @@ static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
>  			if (--left) continue;
>  			length = sprintf(page,"vcc %4d: ",vcc->vci);
>  			if (eni_vcc->rx) {
> -				length += sprintf(page+length,"0x%ld-0x%ld "
> +				length += sprintf(page+length, "0x%lx-0x%lx "
>  				    "(%6ld bytes)",
>  				    (unsigned long) (eni_vcc->recv - eni_dev->ram),
>  				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
