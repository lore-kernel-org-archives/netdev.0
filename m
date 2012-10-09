From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] compat-drivers: update ethernet driver alx in crap dir
Date: Mon, 8 Oct 2012 17:42:09 -0700
Message-ID: <20121009004209.GC9068@kroah.com>
References: <1349400892-25315-1-git-send-email-xiong@qca.qualcomm.com>
 <CAB=NE6VotAu-cugsn4==3TPX0OGPEFtdn1J+5+Rd_YfLcg9YDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiong-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org,
	Ren Cloud <cjren-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6VotAu-cugsn4==3TPX0OGPEFtdn1J+5+Rd_YfLcg9YDQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2012 at 03:25:08PM -0700, Luis R. Rodriguez wrote:
> On Thu, Oct 4, 2012 at 6:34 PM,  <xiong-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> wrote:
> > From: xiong <xiong-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> >
> > 1. support new device id (0x10A0/0x10A1).
> > 2. add DEBUG_FS interface for diag/swoi functions.
> >
> > Signed-off-by: Ren Cloud <cjren-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> > Signed-off-by: xiong <xiong-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> 
> Xiong,
> 
>  -- Vladimir, just a heads up -- this applies to you as well for the
> 802.11ad wil6210 driver
>  -- Greg, some review on your preference on this would be appreciated

Preference on what?  I've never seen this driver before, why wasn't it
submitted to be in the staging tree in the first place?

> The original alx crap patch was added into compat-wireless on the
> linux-3.5.y branch.

What is "crap patch"?  And is this the old driver with the dubios
history keeping it from ever being merged anywhere, or is this something
new?

> Its been two kernel releases and alx is not yet
> upstream and users can only get alx via compat-drivers (technically
> compat-wireless as that was pre v3.7). v3.7 would be the *third*
> release in which this would happen... This is unfair to users and
> consumers of the Linux kernel and derails expectations and our
> arrangements for Linux kernel development. I realize that the goal was
> to get alx upstream ASAP but regardless of what the reason is, its not
> yet upstream. If you cannot work on alx on a timely manner to get
> upstream then please submit the driver to the staging area of the
> Linux kernel that Greg maintains so that other developers who may be
> able to help can submit patches to help you. Under staging your driver
> should be accepted so long as it compiles.
> 
> I will update the documentation for crap/ patches for compat-drivers
> to make it clear now that crap/ patches can be used for adding
> components / pieces of code not yet ready for upstream but as far as
> full new drivers are concerned you only get one kernel release cycle
> for it to linger on crap/ under compat-drivers, if you haven't
> addressed upstreaming yet then it should go to drivers/staging/. That
> is crap/ should only be used as a shortcut because users exist that
> can use the driver but you *do* have a team properly resourced to
> address upstreaming properly in a timely manner.

Why do you even need crap/ at all?  What is keeping drivers like this
(if it isn't the legally dubious driver) from being merged into staging
today?  And if it is the legally dubious driver, well, you had better
not be taking it in your tree either...

confused,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
