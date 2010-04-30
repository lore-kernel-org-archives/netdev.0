From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: sierra_net default m
Date: Fri, 30 Apr 2010 11:49:27 -0700 (PDT)
Message-ID: <20100430.114927.209984393.davem@davemloft.net>
References: <20100430172838.GJ27497@kernel.dk>
	<1272653150.9050.20.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1272653150.9050.20.camel@Linuxdev3>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Date: Fri, 30 Apr 2010 11:45:50 -0700

> OK. Makes sense, so that the kernel does not build the driver if the
> configuration option is not explicitly set.

All non-core drivers should default to "n".

The default controls what the user is suggested to choose when they
run the configuration without an explicit setting in their existing
config.

They should never be told to turn on a driver by default for an
odd-ball piece of hardware.

Even the IDE and ATA disk layers don't default to anything explicitly.

Just remove the default tag altogether.  I see that a bunch of other USB
networking drivers have all sorts of default tags, I wish you didn't
follow their lead. :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
