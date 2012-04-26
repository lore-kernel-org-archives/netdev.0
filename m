From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-04-25
Date: Thu, 26 Apr 2012 14:41:50 -0400
Message-ID: <20120426184150.GG16900@tuxdriver.com>
References: <20120425191418.GC16900@tuxdriver.com>
 <20120425.163926.2209040699696617525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120425.163926.2209040699696617525.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2012 at 04:39:26PM -0400, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Wed, 25 Apr 2012 15:14:19 -0400
> 
> > This is another batch of updates intended for 3.5...
>  ...
> > Please let me know if there are problems!
> 
> There are:
> 
> From 792545c7bc5d6b922d3778dc602e557d64c83551 Mon Sep 17 00:00:00 2001
> From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
> Date: Mon, 23 Apr 2012 19:55:48 -0700
> Subject: [PATCH 88/88] libertas: include sched.h on firmware.c
> 
> Do not assume we have our subsystem including this for us,
> at least for older kernels this is not true. Lets just be
> explicit about this requirement for the usage of wake_up().
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> 
> This is bogus, wake_up() is defined in linux/wait.h, the whole
> point of the linux/sched.h split up is so that linux/sched.h
> includes could be removed and replaced with actual dependencies.

This is completely my bad.  Anyway, Felix already added that include
in that file a few lines later in order to pick-up the definitions
for TASK_NORMAL and TASK_UNINTERRUPTIBLE.  I'll just drop Luis's patch.

> Also, please don't accept any patches from Luis that add those
> #undef pr_fmt things to the atheros drivers.
> 
> He tried to add it an ethernet driver, and I asked him to explain
> exactly why he's doing and that if it's appropriate then it's
> appropriate everywhere not just in a few specific drivers.  He failed
> to respond to me, and therefore failed to explain the situation and
> address my concerned.  And then I saw just today that he's submitting
> the same patch to wireless drivers.  That's not acceptable.
> 
> Thanks.

OK.  I think the compat-wireless guys have found a different solution
anyway.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
