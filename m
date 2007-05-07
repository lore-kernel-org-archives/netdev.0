From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 07 May 2007 19:09:20 -0400
Message-ID: <463FB1A0.3070608@garzik.org>
References: <20070507175121.GF5125@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070507175121.GF5125-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 15700770ef7c5d12e2f1659d2ddbeb3f658d9f37:
>   Linus Torvalds (1):
>         Merge git://git.kernel.org/.../sam/kbuild
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake (1):
>       zd1211rw: Add ID for ZyXEL AG-225H v2
> 
> Geert Uytterhoeven (1):
>       mac80211: include <linux/delay.h> instead of <asm/delay.h>
> 
> Ivo van Doorn (1):
>       Add 93cx6 eeprom library
> 
> John W. Linville (1):
>       libertas: fix for wireless Kconfig changes
> 
> Larry Finger (3):
>       ieee80211: add ieee80211_channel_to_freq
>       ieee80211: include frequency in scan results
>       bcm43xx: Remove dead configuration variable CONFIG_947XX
> 
> Matthew Davidson (1):
>       zd1211rw: Add ID for Sitecom WL-117
> 
> Michael Wu (1):
>       Add rtl8187 wireless driver
> 
> Ulrich Kunitz (1):
>       zd1211rw: Added new USB id for Planex GW-US54ZGL


The normal development process is:

* commit new code to your repository
* that goes into -mm for public testing and review
* merge window opens
* the code that has seen public testing and review goes upstream

The general idea is everything you want in 2.6.22 should be prepared and 
in -mm BEFORE 2.6.21 is released, and the 2.6.22 merge window opens.

It's quite normal for fixes and minor changes to trickle in after the 
push that follows the merge window opening.  But new drivers that have 
not been through this process do not fall under "fixes and minor changes."

I also did not see any response to my "better as a single file driver" 
suggestion.

So, I'll pull if you remove the two late additions.

	Jeff
