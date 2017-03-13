From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] usbnet: smsc95xx: Reduce logging noise
Date: Mon, 13 Mar 2017 15:32:36 -0700 (PDT)
Message-ID: <20170313.153236.1183838776173721070.davem@davemloft.net>
References: <1489196721-12888-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org, UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489196721-12888-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Date: Fri, 10 Mar 2017 17:45:21 -0800

> An insert/remove stress test generated the following log message sequence.
...
> Use netdev_dbg() instead of netdev_warn() for the repeating messages
> to reduce logging noise.
> 
> Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>

The problem I have with changes like this is that outside of your
stress test situation these messages are extremely useful but will
now be hidden making diagnosis of problems more difficult.

Perhaps you can check the error code or some piece of USB device
state to see if there was a disconnect, and elide the log message
in that case specifically.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
