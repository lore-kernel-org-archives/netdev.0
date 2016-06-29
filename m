From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-06-29
Date: Wed, 29 Jun 2016 09:10:14 +0200
Message-ID: <1467184215-4598-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Another (pretty old) bug showed up, and I have a single fix for it
from Jouni; would be nice to still get it in, but it's in mesh which
seems to mostly have users who integrate everything themselves.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 3d5fdff46c4b2b9534fa2f9fc78e90a48e0ff724:

  wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel (2016-06-09 09:56:11 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-06-29

for you to fetch changes up to 126e7557328a1cd576be4fca95b133a2695283ff:

  mac80211: Fix mesh estab_plinks counting in STA removal case (2016-06-28 12:39:50 +0200)

----------------------------------------------------------------
A single fix:
 * fix mesh peer link counter, decrement wasn't always done at all

----------------------------------------------------------------
Jouni Malinen (1):
      mac80211: Fix mesh estab_plinks counting in STA removal case

 net/mac80211/mesh.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
