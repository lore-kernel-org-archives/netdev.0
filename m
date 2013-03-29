From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2 v3] usbnet: allow status interrupt URB to always be
 active
Date: Fri, 29 Mar 2013 15:20:43 -0400 (EDT)
Message-ID: <20130329.152043.1285405417950961484.davem@davemloft.net>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<1364488207.1877.20.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, phil-ydcDiazATMQ@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364488207.1877.20.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Thu, 28 Mar 2013 11:30:07 -0500

> +	if (test_bit (EVENT_DEV_ASLEEP, &dev->flags))
> +		return -EINVAL;
> +
> +	mutex_lock (&dev->interrupt_mutex);

Please do not put a space between a function name and the openning
parenthesis in the call.

These are not C language primitives (where the space would be
appropriate, f.e. "if (") they are C functions.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
