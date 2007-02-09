From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull "upstream" branch of wireless-2.6
Date: Fri, 09 Feb 2007 16:12:49 -0500
Message-ID: <45CCE3D1.3030303@garzik.org>
References: <20070202212747.GC9382@tuxdriver.com> <45C917EF.1060307@garzik.org> <20070207211117.GC6109@tuxdriver.com> <20070209201306.GA2580@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070209201306.GA2580-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Wed, Feb 07, 2007 at 04:11:17PM -0500, John W. Linville wrote:
>> On Tue, Feb 06, 2007 at 07:06:07PM -0500, Jeff Garzik wrote:
>>> Would you mind rebasing & resending, kind sir?
>> By your command! :-)
> 
> And once more, now with feeling! :-)
> 
> ---
> 
> The following changes since commit 62d0cfcb27cf755cebdc93ca95dabc83608007cd:
>   Linus Torvalds (1):
>         Linux 2.6.20
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake (1):
>       zd1211rw: Remove noisy debug message
> 
> Larry Finger (5):
>       bcm43xx: Fix problem with >1 GB RAM
>       bcm43xx: Fix scaling error for 'iwlist rate' information
>       bcm43xx: Fix scaling error for 'iwlist freq' information
>       bcm43xx: Check error returns in initialization routines
>       ieee80211: Fix sparse warning
> 
> Maxime Austruy (1):
>       zd1211rw: fix potential leak in usb_init
> 
> Michael Buesch (1):
>       bcm43xx: Enable fwpostfix in nondebug bcm43xx
> 
> Robert P. J. Day (2):
>       Rename IPW2100 debugging macros to not look like config options.
>       Replace incorrect macro name "WIRELESS_EXT" with "CONFIG_WIRELESS_EXT"
> 
> Ulrich Kunitz (3):
>       zd1211rw: Reset device in the probe call
>       zd1211rw: Fixed array size issue in reset_mode
>       zd1211rw: Added error stats update
> 
>  drivers/net/wireless/bcm43xx/bcm43xx.h      |    1 +
>  drivers/net/wireless/bcm43xx/bcm43xx_dma.c  |  171 +++++++++++++++++++--------
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c |   25 +++--
>  drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |   28 ++--
>  drivers/net/wireless/ipw2100.c              |   16 ++--
>  drivers/net/wireless/zd1211rw/zd_mac.c      |   44 ++++++--
>  drivers/net/wireless/zd1211rw/zd_usb.c      |   12 ++
>  net/core/net-sysfs.c                        |    4 +-
>  net/ieee80211/ieee80211_tx.c                |    3 -
>  9 files changed, 210 insertions(+), 94 deletions(-)

pulled, thanks


-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
