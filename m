From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH (for some future time)] drivers/net: Convert unbounded
 kzalloc calls to kcalloc
Date: Thu, 12 Aug 2010 09:48:14 +0300
Message-ID: <1281595694.4440.2.camel@powerslave>
References: <1281546168.3976.39.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: ext Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281546168.3976.39.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-08-11 at 19:02 +0200, ext Joe Perches wrote:
> These changes may be slightly safer in some instances.
> 
> There are other kzalloc calls with a multiply, but those
> calls are typically "small fixed #" * sizeof(some pointer)"
> and those are not converted.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

[...]

>  drivers/net/wireless/wl12xx/wl1271_scan.c |    2 +-

[...]

> diff --git a/drivers/net/wireless/wl12xx/wl1271_scan.c b/drivers/net/wireless/wl12xx/wl1271_scan.c
> index fec43ee..30dc100 100644
> --- a/drivers/net/wireless/wl12xx/wl1271_scan.c
> +++ b/drivers/net/wireless/wl12xx/wl1271_scan.c
> @@ -248,7 +248,7 @@ int wl1271_scan(struct wl1271 *wl, const u8 *ssid, size_t ssid_len,
> 
>         wl->scan.req = req;
> 
> -       wl->scan.scanned_ch = kzalloc(req->n_channels *
> +       wl->scan.scanned_ch = kcalloc(req->n_channels,
>                                       sizeof(*wl->scan.scanned_ch),
>                                       GFP_KERNEL);
>         wl1271_scan_stm(wl);

For the wl1271 part:

Acked-by: Luciano Coelho <luciano.coelho@nokia.com>

-- 
Cheers,
Luca.
