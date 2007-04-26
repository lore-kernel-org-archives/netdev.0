From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/9] wext: remove dead debug code
Date: Thu, 26 Apr 2007 09:46:32 -0700
Message-ID: <20070426164632.GA22576@bougret.hpl.hp.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180847.982382000@sipsolutions.net>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070424180847.982382000-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 08:07:35PM +0200, Johannes Berg wrote:
> This patch kills a whole bunch of code that can only ever be used by
> defining some things in wext.c. Also, the things that are printed are
> mostly useless since the API is fairly well-tested.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

	Hi,

	Overall ok with the patches. Comments on a few of them...
	I personally would not remove this DEBUG code, because it
decreases the overall maitainability of the code.
	First, it does not only help to debug the API, but it can be
used to debug userspace and drivers in some extreme cases.
	Second, this debugging act as documentation. He points out
which are the important variables and how they are used at critical
points of the code.
	As this debug is localised, and compiled out, it does not
bother anybody and should stay.

	Regards,

	Jean
