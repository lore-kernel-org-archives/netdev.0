From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] net: usb: cdc_ncm: Adding support for two new Dell
 devices
Date: Wed, 16 Dec 2015 11:12:34 -0600
Message-ID: <1450285954.23793.15.camel@redhat.com>
References: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450258765-11215-1-git-send-email-dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-16 at 10:39 +0100, Daniele Palmas wrote:
> This patch series add support in the cdc_ncm driver for two devices
> based on the same platform, that are different only for carrier
> customization.
> 
> The devices do not have ARP capabilities.
> 
> Daniele Palmas (2):
>   net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband
>     Card
>   net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband
> Card

Quite interesting; Google knows nothing about these devices that I can
find.  What platform are these based on?

But in any case, since these blocks are almost identical to the DW5550
block, maybe update the comments to indicate that they need NOARP
unlike the MBM platform that the 5550 is based on?

Dan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
