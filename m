From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] isdn/gigaset: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 12:28:52 -0700 (PDT)
Message-ID: <20170313.122852.1573749710003810412.davem@davemloft.net>
References: <20170313123901.28298-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org, pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org,
        gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hjlipp-S0/GAf8tV78@public.gmane.org
To: johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170313123901.28298-1-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Mon, 13 Mar 2017 13:39:01 +0100

> Make sure to check the number of endpoints to avoid dereferencing a
> NULL-pointer should a malicious device lack endpoints.
> 
> Fixes: cf7776dc05b8 ("[PATCH] isdn4linux: Siemens Gigaset drivers -
> direct USB connection")
> Cc: stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>	# 2.6.17
> Cc: Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>
> 
> Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
