From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v5] wlcore: spi: add wl18xx support
Date: Mon, 18 Jul 2016 20:04:19 +0300
Message-ID: <87vb02x4h8.fsf@kamboji.qca.qualcomm.com>
References: <8665E2433BC68541A24DFFCA87B70F5B36156367@DFRE01.ent.ti.com>
	<8665E2433BC68541A24DFFCA87B70F5B3615D8AA@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree\@vger.kernel.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi\@vger.kernel.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer\, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B3615D8AA-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
	(Eyal Reizer's message of "Sun, 17 Jul 2016 06:36:11 +0000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org> writes:

> Add support for using with both wl12xx and wl18xx.
>
> - all wilink family needs special init command for entering wspi mode.
>   extra clock cycles should be sent after the spi init command while the
>   cs pin is high.
> - Use inverted chip select for sending a dummy 4 bytes command that
>   completes the init stage.
>
> Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
> v1->v2:update device tree bindings configuration
> v2->v3:revert from manual gpio manipulation. use inverted chip select 
> instead for sending the extra init cycle which, achieves the same hardware 
> purpose.
> update device tree bindings docucmentation accordingly
> v3->v4: Remove redundant data form binding documentation and fix chip 
> select number mismatch in wl1271 example
> v4->v5: Rebase on top of head of wireless-drivers-next

You now sent me two patches with v5 which is just confusing. To make the
life of maintainers easier ALWAYS increase the revision number, no
matter how small the change is.

But the "latter" v5 is corrupted somehow in patchwork:

https://patchwork.kernel.org/patch/9233597/

The "former" v5 again looks ok:

https://patchwork.kernel.org/patch/9222403/

I can't immeaditely see why that happened, but please resend.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
