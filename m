From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v1] NFC: netlink: Use error code from
 nfc_activate_target()
Date: Wed, 5 Apr 2017 10:16:07 +0200
Message-ID: <20170405081544.GC2136@zurbaran.ger.intel.com>
References: <20170322192058.30193-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170322192058.30193-1-andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andy,

On Wed, Mar 22, 2017 at 09:20:58PM +0200, Andy Shevchenko wrote:
> It looks like a typo to assign a return code to a variable which is not
> used. Found due to a compiler warning:
> 
> net/nfc/netlink.c: In function ‘nfc_genl_activate_target’:
> net/nfc/netlink.c:903:6: warning: variable ‘rc’ set but not used [-Wunused-but-set-variable]
>   int rc;
>         ^~
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
>  net/nfc/netlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Applied, thanks.

Cheers,
Samuel.
