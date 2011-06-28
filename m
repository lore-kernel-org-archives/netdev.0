From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Prevent buffer overflow in l2cap config
 request
Date: Tue, 28 Jun 2011 14:59:37 -0300
Message-ID: <20110628175937.GA23183@joana>
References: <1308919085.5295.11.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Dan Rosenberg <drosenberg-PiUznwcHFHrqlBn2x/YWAg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1308919085.5295.11.camel@dan>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dan,

* Dan Rosenberg <drosenberg-PiUznwcHFHrqlBn2x/YWAg@public.gmane.org> [2011-06-24 08:38:05 -0400]:

> A remote user can provide a small value for the command size field in
> the command header of an l2cap configuration request, resulting in an
> integer underflow when subtracting the size of the configuration request
> header.  This results in copying a very large amount of data via
> memcpy() and destroying the kernel heap.  Check for underflow.
> 
> Signed-off-by: Dan Rosenberg <drosenberg-PiUznwcHFHrqlBn2x/YWAg@public.gmane.org>
> Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  net/bluetooth/l2cap_core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

Applied, thanks.

	Gustavo
