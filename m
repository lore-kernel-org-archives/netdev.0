From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 3/9] wext: remove dead debug code
Date: Thu, 26 Apr 2007 20:55:49 -0400
Message-ID: <20070427005549.GB25332@tuxdriver.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180847.982382000@sipsolutions.net> <20070426164632.GA22576@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070426164632.GA22576-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 09:46:32AM -0700, Jean Tourrilhes wrote:

> 	Overall ok with the patches. Comments on a few of them...
> 	I personally would not remove this DEBUG code, because it
> decreases the overall maitainability of the code.
> 	First, it does not only help to debug the API, but it can be
> used to debug userspace and drivers in some extreme cases.
> 	Second, this debugging act as documentation. He points out
> which are the important variables and how they are used at critical
> points of the code.
> 	As this debug is localised, and compiled out, it does not
> bother anybody and should stay.

Jean,

I think the code looks cleaner with the patch applied.  If the
debugging is valuable to you, I recommend that you save this patch
and reverse apply it before future work.

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
