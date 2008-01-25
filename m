From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 10/14] [rndis_host] Add rndis_early_init function
	pointer to 'struct rndis_data'.
Date: Fri, 25 Jan 2008 15:14:50 +0200
Message-ID: <1201266890.7266.0.camel@localhost>
References: <20080120001438.25718.96722.stgit@fate.lan>
	 <200801241710.35528.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200801241710.35528.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-01-24 at 17:10 -0800, David Brownell wrote:
> Could this -- and #11/14 -- instead be generalized a bit,
> so they're not RNDIS-specific?  At least in name; the
> only user for now would be the rndis_host code.
> 
> The generalization would presumably be "early_init" and
> "link_change", paired with doc comments reflecting that
> they're usable by any driver stack built over the usbnet
> framework core.
> 
> There's no point IMO to having generalizable hooks be
> restricted this way.

Sure.
