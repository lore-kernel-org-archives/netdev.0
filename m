From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 0/8] RFC: Wireless Extensions for rndis_host
Date: Sat, 22 Dec 2007 17:49:19 -0800
Message-ID: <20071223014919.4FFC1166E03@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjd-a1rhEgazXTw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602942818-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> Subject: [PATCH 0/8] RFC: Wireless Extensions for rndis_host
> Date: Sat, 22 Dec 2007 22:51:26 +0100
>
> Hello all,
>
> I have here a patchset that needs some review.
> This patchset adds wireless extensions for rndis_host to
> enable support for RNDIS based USB wireless LAN adapters
> (e.g. Linksys WUSB54GS, Belkin F05D7051).

Cool!  We always like to see support for more USB peripherals.
Even (especially?) if they'e previously been Windows-only,
penguin-deprived hardware.  ;)

Is all that stuff adequately documented?  What I recall from
working with RNDIS before is that docs were lacking in some
critical details, and were sometimes wrong.


> In this patchset:
>  1.  Fix sparse warning: returning void valued expression
>  2.  Hardwire CDC descriptors when missing
>  3.  Use 1KB buffer in rndis_unbind
>  4.  Halt device if rndis_bind fails
>  5.  Fix rndis packet filter flags
>  6.  Split up rndis_host.c
>  7.  Add Wireless Extensions for rndis_host
>  8.  Use wlan device name for RNDIS wireless devices
>
> The first five patches are more generic fixes that I think
> can be applied as they are. Of these, patch 2 is required
> to get these wireless devices working. 

I had no problem with those first five.  I take it none of
those should be prioritized for 2.6.24 integration?


> Patches 6-8 introduce some larger changes that may need a
> closer look.

And you saw my feedback on those.  Minimally, please split
out the usbnet core extensions, instead of combining them
with rndis_wext patches ... and on first princples I'd
think rndis_wext should live in its own module.

I just skimmed patch #7.  There are people far more aware
of the issues with Linux wireless drivers than me.  :)

- Dave


> All these patches should be applied in order.
> The entire series should apply cleanly to current linux
> kernel and net-2.6.25 trees.
>
> regards,
> Bjorge Dijkstra
>
