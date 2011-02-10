From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: l2cap: fix 1 byte infoleak to userspace
Date: Thu, 10 Feb 2011 16:11:33 -0200
Message-ID: <20110210181133.GA2173@joana>
References: <1297360783-21452-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1297360783-21452-1-git-send-email-segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Vasiliy,

* Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> [2011-02-10 20:59:42 +0300]:

> Structure l2cap_options has one padding byte between max_tx and
> txwin_size fields.  This byte in "opts" is copied to userspace
> uninitialized.
> 
> Signed-off-by: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> ---
>  Compile tested only.
> 
>  net/bluetooth/l2cap_sock.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

Patch has been applied, thanks.

-- 
Gustavo F. Padovan
http://profusion.mobi
