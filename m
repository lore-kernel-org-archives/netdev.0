From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCHv1 bluetooth-next] cc2520: set the default fifo pin value
 from platform data
Date: Mon, 10 Aug 2015 21:08:24 +0530
Message-ID: <55C8C570.9060102@gmail.com>
References: <BLU168-W12778BE0A70F0EA756A9E8CD6700@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: LIYONG <sdliyong@gmail.com>,
	"alex.aring@gmail.com" <alex.aring@gmail.com>,
	"linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLU168-W12778BE0A70F0EA756A9E8CD6700@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yup...  :-)  Your name in the From (LIYONG) address is different from SOB (Yong Li) address.
It should be same, please fix your email-client.

On 08/10/2015 12:59 PM, LIYONG wrote:

> In case of the device tree support is disabled, the fifo_pin is uninitialized, this
> patch will set the fifo_pin value based on platform data
>
> Signed-off-by: Yong Li<sdliyong@gmail.com>
> ---
>   drivers/net/ieee802154/cc2520.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> index 613dae5..c5b54a1 100644
> --- a/drivers/net/ieee802154/cc2520.c
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -833,6 +833,7 @@ static int cc2520_get_platform_data(struct spi_device *spi,
>                  if (!spi_pdata)
>                          return -ENOENT;
>                  *pdata = *spi_pdata;
> +               priv->fifo_pin = pdata->fifo;
>                  return 0;
>          }
>
> --
> 2.1.0
>
>   		 	   		

This patch is not applying.

Please use 'git format-patch' to generate the patch. And send it by 'git send-email'

In your case:
	git commit -am -s "cc2520: set the default fifo pin value from platform data"
	git format-patch --subject-prefix="PATCH v2 bluetooth-next" -1
	git send-email 0001-....


-- 
Varka Bhadram.
