From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 10/14] [rndis_host] Add early_init function pointer to
	'struct rndis_data'.
Date: Sun, 27 Jan 2008 21:11:03 +0200
Message-ID: <1201461063.3663.24.camel@localhost>
References: <20080125225032.11716.77713.stgit@fate.lan>
	 <20080125225128.11716.59998.stgit@fate.lan>
	 <200801270814.43760.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bjd-a1rhEgazXTw@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200801270814.43760.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-01-27 at 08:14 -0800, David Brownell wrote:
> On Friday 25 January 2008, Jussi Kivilinna wrote:
> > Function pointer is for 'subminidrivers' that need to do work on device 
> > right after minidriver has initialized hardware.
> > 
> > For example, rndis_wlan setting device specific configuration parameters
> > with OID_GEN_RNDIS_CONFIG_PARAMETER right after rndis_host has 
> > initialized hardware with RNDIS_INIT.
> > 
> > Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> 
> Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> 
> ... though I'm not sure I'd coin a term like "subminidriver".  ;)

Hm.. sure there could have been better ways of explaining that but with
my inadequate english skills that's what came out first :)
