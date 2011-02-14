From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] bluethooth: sco: fix information leak to userspace
Date: Mon, 14 Feb 2011 12:36:47 -0200
Message-ID: <20110214143647.GB2597@joana>
References: <1297680867-11551-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1297680867-11551-1-git-send-email-segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Vasiliy,

* Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> [2011-02-14 13:54:26 +0300]:

> struct sco_conninfo has one padding byte in the end.  Local variable
> cinfo of type sco_conninfo is copied to userspace with this uninizialized
> one byte, leading to old stack contents leak.
> 
> Signed-off-by: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> ---
>  Compile tested.
> 
>  net/bluetooth/sco.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

Applied as well, thanks.

-- 
Gustavo F. Padovan
http://profusion.mobi
