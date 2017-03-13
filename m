From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: wimax/i2400m: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 12:28:57 -0700 (PDT)
Message-ID: <20170313.122857.396618777046322808.davem@davemloft.net>
References: <20170313124203.28490-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-wimax-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170313124203.28490-1-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Mon, 13 Mar 2017 13:42:03 +0100

> Make sure to check the number of endpoints to avoid dereferencing a
> NULL-pointer or accessing memory beyond the endpoint array should a
> malicious device lack the expected endpoints.
> 
> The endpoints are specifically dereferenced in the i2400m_bootrom_init
> path during probe (e.g. in i2400mu_tx_bulk_out).
> 
> Fixes: f398e4240fce ("i2400m/USB: probe/disconnect, dev init/shutdown
> and reset backends")
> Cc: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> 
> Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
