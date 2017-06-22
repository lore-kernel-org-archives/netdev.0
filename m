From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] nfc: nci: remove unnecessary null check
Date: Fri, 23 Jun 2017 00:35:24 +0200
Message-ID: <20170622223524.GG21214@zurbaran.ger.intel.com>
References: <28317503-e721-2564-a9ff-82182aa0644a@roeck-us.net>
 <20170613163718.GA5375@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170613163718.GA5375@embeddedgus>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Gustavo,

On Tue, Jun 13, 2017 at 11:37:18AM -0500, Gustavo A. R. Silva wrote:
> Remove unnecessary NULL check for pointer conn_info.
> conn_info is set in list_for_each_entry() using container_of(),
> which is never NULL.
> 
> Addresses-Coverity-ID: 1362349
> Cc: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
> Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
> ---
>  net/nfc/nci/core.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
Applied to nfc-next, thanks.

Cheers,
Samuel.
