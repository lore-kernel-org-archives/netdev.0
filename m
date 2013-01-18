From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 2/2] net: asix: handle packets crossing URB
 boundaries
Date: Fri, 18 Jan 2013 14:14:17 -0500 (EST)
Message-ID: <20130118.141417.1689839133859854414.davem@davemloft.net>
References: <1358346247-10579-1-git-send-email-dev@lynxeye.de>
	<1358346247-10579-2-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358346247-10579-2-git-send-email-dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Date: Wed, 16 Jan 2013 15:24:07 +0100

> ASIX AX88772B started to pack data even more tightly. Packets and the ASIX packet
> header may now cross URB boundaries. To handle this we have to introduce
> some state between individual calls to asix_rx_fixup().
> 
> Signed-off-by: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
