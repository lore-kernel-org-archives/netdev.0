From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v7] wlcore: spi: add wl18xx support
Date: Tue, 19 Jul 2016 10:22:18 +0300
Message-ID: <87poqaum6t.fsf@kamboji.qca.qualcomm.com>
References: <1468911482-32560-1-git-send-email-eyalr@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
To: Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468911482-32560-1-git-send-email-eyalr-l0cyMroinI0@public.gmane.org> (Eyal Reizer's
	message of "Tue, 19 Jul 2016 09:58:02 +0300")
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> From: Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
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

This looks ok in patchwork:

https://patchwork.kernel.org/patch/9235983/

Because you used ti.com in S-o-b I assume From should also use ti.com. I
can fix that before I apply but please confirm that's really the case?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
