From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Mon, 17 Dec 2007 16:10:13 -0500
Message-ID: <4766E5B5.1080400@garzik.org>
References: <20071216043148.GE3096@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071216043148.GE3096-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
> 
> A few more fixes for 2.6.24...let me know if there are any problems!
> 
> Thanks,
> 
> John
> 
> P.S.  The zd1211rw patch is already in netdev-2.6#upstream, but it
> belongs in 2.6.24 as well.
> 
> ---
> 
> Individual patches available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik
> 
> ---
> 
> The following changes since commit 82d29bf6dc7317aeb0a3a13c2348ca8591965875:
>   Linus Torvalds (1):
>         Linux 2.6.24-rc5
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> Adrian Bunk (1):
>       wireless/ipw2200.c: add __dev{init,exit} annotations
> 
> Andrew Morton (1):
>       bcm43xx_debugfs sscanf fix
> 
> Cyrill Gorcunov (2):
>       ieee80211_rate: missed unlock
>       iwlwifi3945/4965: fix rate control algo reference leak
> 
> Dan Williams (1):
>       libertas: select WIRELESS_EXT
> 
> Larry Finger (1):
>       b43: Fix rfkill radio LED
> 
> Stefano Brivio (1):
>       libertas: add Dan Williams as maintainer
> 
> Ulrich Kunitz (1):
>       zd1211rw: Fix alignment problems
> 
> Zhu Yi (1):
>       iwlwifi: fix rf_kill state inconsistent during suspend and resume
> 
>  MAINTAINERS                                    |    6 ++++
>  drivers/net/wireless/Kconfig                   |    1 +
>  drivers/net/wireless/b43/leds.c                |    4 ++
>  drivers/net/wireless/b43/main.c                |   22 +++++++-------
>  drivers/net/wireless/b43/rfkill.c              |   37 ++++++++++++++++++++---
>  drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |    2 +-
>  drivers/net/wireless/ipw2200.c                 |    7 ++--
>  drivers/net/wireless/iwlwifi/iwl3945-base.c    |    5 ++-
>  drivers/net/wireless/iwlwifi/iwl4965-base.c    |    5 ++-
>  drivers/net/wireless/zd1211rw/zd_mac.c         |   10 +++++-
>  net/mac80211/ieee80211_rate.c                  |    1 +
>  11 files changed, 76 insertions(+), 24 deletions(-)

pulled
