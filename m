From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 00/14][v3]: Driver for Wireless RNDIS USB devices.
Date: Fri, 25 Jan 2008 15:09:24 -0800
Message-ID: <200801251509.24377.david-b@pacbell.net>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bjd-a1rhEgazXTw@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080125225032.11716.77713.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 25 January 2008, Jussi Kivilinna wrote:
> Hello,
> 
> Here is the third try on wireless RNDIS patchset.
> 
> Patches 1-9 are from second patchset (with name change rndis_wext -> rndis_wlan
> in comments where needed):
>  1. Fix sparse warning: returning void valued expression
>  2. [cdc_ether] Hardwire CDC descriptors when missing
>  3. [rndis_host] Use 1KB buffer in rndis_unbind
>  4. [rndis_host] Halt device if rndis_bind fails
>  5. [rndis_host] Fix rndis packet filter flags
>  6. [usbnet] Use wlan device name for RNDIS wireless devices
>  7. [rndis_host] Split up rndis_host.c
>  8. [rndis_host] export functions
>  9. [usbnet] add driver_priv pointer to 'struct usbnet'

If they're the same, my ack (as maintainer for that infrastructure
and, for now, rndis_host) still stands.  I won't look at them again.


> Changed patches 10-14:
> 10. [rndis_host] Add early_init function pointer to 'struct rndis_data'.
> 11. [rndis_host] Add link_change function pointer to 'struct rndis_data'.
> 12. [rndis_host] Add RNDIS physical medium checking into generic_rndis_bind()
> 13. Move usbnet.h and rndis_host.h to include/linux/usb
> 14. Add new driver 'rndis_wlan' for wireless RNDIS devices.
> 
