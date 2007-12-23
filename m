From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 7/8] Add Wireless Extensions to rndis_host
Date: Sat, 22 Dec 2007 17:27:32 -0800
Message-ID: <20071223012732.B547F166E03@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <11983602951628-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602951628-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> Subject: [PATCH 7/8] Add Wireless Extensions to rndis_host
> Date: Sat, 22 Dec 2007 22:51:33 +0100
>
> The bulk of this patch is the addition of a new file that
> implements the wireless extensions for RNDIS devices.
> The rest are some smaller changes to usbnet and rndis_host
> to hook the wireless extensions into them:
> * a private data pointer is added to usbnet.
> * a callback is added to driver_info to signal link state changes.
> * a physical medium type check is added to rndis_bind to check for
>   wireless lan devices and turn on the wireless extensions.
> * and finally a Kconfig option to enable/disable this all.
>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>

I'm basically fine with this, but I'll hold off any ack until the
issue with the preceding patch (6/8) is resolved.  That would boil
down to making this a standalone module, or knowing why that's not
such a good idea.

I'd prefer to see the usbnet core extension packaged separately
instead of buried in this patch.  :)

And I think a MAINTAINERS update for rndis_wext would be appropriate.
No way can I take care of that code!

(In fact, would you feel comfortable taking over rndis_host too?)

- Dave


> ---
>  drivers/net/usb/Kconfig      |    7 +
>  drivers/net/usb/Makefile     |    4 +
>  drivers/net/usb/rndis_base.c |   50 +-
>  drivers/net/usb/rndis_host.h |   18 +
>  drivers/net/usb/rndis_wext.c | 2177 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/usb/usbnet.h     |    4 +
>  6 files changed, 2255 insertions(+), 5 deletions(-)
>  create mode 100644 drivers/net/usb/rndis_wext.c
