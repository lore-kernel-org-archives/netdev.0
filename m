From: Petr Mladek <pmladek-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH 11/13] timer: Remove expires argument from
 __TIMER_INITIALIZER()
Date: Wed, 11 Oct 2017 12:15:14 +0200
Message-ID: <20171011101514.GA2882@pathway.suse.cz>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-12-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Harish Patil <harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Julian Wiedmann <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Manish Chopra <manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Martin K. Petersen"
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1507159627-127660-12-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed 2017-10-04 16:27:05, Kees Cook wrote:
> The expires field is normally initialized during the first mod_timer()
> call. It was unused by all callers, so remove it from the macro.
> 
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  include/linux/kthread.h   | 2 +-
>  include/linux/timer.h     | 5 ++---
>  include/linux/workqueue.h | 2 +-
>  3 files changed, 4 insertions(+), 5 deletions(-)

I was primary interested into the change in kthread.h. But the entire
patch is simple and looks fine:

Reviewed-by: Petr Mladek <pmladek-AlSwsSmVLrQ@public.gmane.org>

Best Regards,
Petr
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
