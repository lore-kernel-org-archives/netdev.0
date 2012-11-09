From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 3/5] usbnet: smsc95xx: fix memory leak in
 smsc95xx_suspend
Date: Fri, 09 Nov 2012 02:25:20 -0500 (EST)
Message-ID: <20121109.022520.1078854628056136345.davem@davemloft.net>
References: <1352213588-8948-1-git-send-email-ming.lei@canonical.com>
	<1352213588-8948-4-git-send-email-ming.lei@canonical.com>
	<CAEtNAxntrPne0AxqR2Pn-Vrrv_R12U-CxmW6=mFSfUS6U3BMKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mankad.maulik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAEtNAxntrPne0AxqR2Pn-Vrrv_R12U-CxmW6=mFSfUS6U3BMKg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maulik Mankad <mankad.maulik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 9 Nov 2012 12:28:17 +0530

> We don't need memset() here.
> May be command[2] = {0}; offset[2] = {0}; crc[4] = {0}; is enough.

The compiler can see this an will eliminate the unnecessary
clears.

So it's better to use memset and make the code much clearer
and easier to audit.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
