From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH][next] ieee802154: atusb: make two structures static,
 fixes warnings
Date: Tue, 26 Sep 2017 15:45:09 +0200
Message-ID: <44e984b7-7d41-2c96-30cc-f4b84dd1aa3d@osg.samsung.com>
References: <20170926131836.15171-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Alexander Aring <alex.aring@gmail.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170926131836.15171-1-colin.king@canonical.com>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/26/2017 03:18 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The arrays atusb_chip_data and hulusb_chip_data are local to the source
> and do not need to be in global scope, so make them static. Also
> remove unnecessary forward declaration of atusb_chip_data.
> 
> Cleans up sparse warnings:
> symbol 'atusb_chip_data' was not declared. Should it be static?
> symbol 'hulusb_chip_data' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ieee802154/atusb.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/atusb.c b/drivers/net/ieee802154/atusb.c
> index 115fa3f37a86..8b0718de568f 100644
> --- a/drivers/net/ieee802154/atusb.c
> +++ b/drivers/net/ieee802154/atusb.c
> @@ -45,8 +45,6 @@
>  #define ATUSB_ALLOC_DELAY_MS	100	/* delay after failed allocation */
>  #define ATUSB_TX_TIMEOUT_MS	200	/* on the air timeout */
>  
> -struct atusb_chip_data;
> -
>  struct atusb {
>  	struct ieee802154_hw *hw;
>  	struct usb_device *usb_dev;
> @@ -767,14 +765,14 @@ atusb_set_promiscuous_mode(struct ieee802154_hw *hw, const bool on)
>  	return 0;
>  }
>  
> -struct atusb_chip_data atusb_chip_data = {
> +static struct atusb_chip_data atusb_chip_data = {
>  	.t_channel_switch = 1,
>  	.rssi_base_val = -91,
>  	.set_txpower = atusb_set_txpower,
>  	.set_channel = atusb_set_channel,
>  };
>  
> -struct atusb_chip_data hulusb_chip_data = {
> +static struct atusb_chip_data hulusb_chip_data = {
>  	.t_channel_switch = 11,
>  	.rssi_base_val = -100,
>  	.set_txpower = hulusb_set_txpower,
> 

This patch has been applied to the wpan-next tree and will be
part of the next pull request to net-next. Thanks!

regards
Stefan Schmidt
