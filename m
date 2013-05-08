From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2 v6 RESEND] sierra_net: keep status interrupt URB
 active
Date: Wed, 08 May 2013 13:14:34 -0700 (PDT)
Message-ID: <20130508.131434.1761984633661397541.davem@davemloft.net>
References: <1367875763.31762.9.camel@dcbw.foobar.com>
	<1367876096.31762.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, phil-ydcDiazATMQ@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367876096.31762.14.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Mon, 06 May 2013 16:34:56 -0500

> The driver and firmware sync up through SYNC messages, and the
> firmware's affirmative reply to these SYNC messages appears to be the
> "Reset" indication received via the status interrupt endpoint.  Thus the
> driver needs the status interrupt endpoint always active so that the
> Reset indication can be received even if the netdev is closed, which is
> the case right after device insertion.
> 
> If the Reset indication is not received by the driver, it continues
> sending SYNC messages to the firmware, which crashes about 10 seconds
> later and the device stops responding.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
