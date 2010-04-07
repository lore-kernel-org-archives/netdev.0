From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
Date: Wed, 7 Apr 2010 14:14:33 -0700
Message-ID: <201004071414.33917.david-b@pacbell.net>
References: <1270599787.8900.8.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1270599787.8900.8.camel@Linuxdev4-laptop>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 April 2010, you wrote:
Recall that the reason to avoid sending zero length packts
(ZLPs) is that many systems don't cope well with them...

The ""don't cope well" can be at the hardware level,
or drivers not limited to device firmware.  I've seen
the failures be very context-dependent .... as in, one
standalone ZLP might work, but mix it in with back-to-back
delivery of other packets and trouble ensues...
  
In short, it's hard to know which combinations of
hardware an firmware would need it .... versus which
ones it would break.

... and thus risky to try sending ZLPs through systems
shere for many years) we've carefully avoided doing that.


- Dave
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
