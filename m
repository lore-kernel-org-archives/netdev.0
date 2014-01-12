From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 0/3 V2] iFixes for b43 and b43legacy
Date: Sun, 12 Jan 2014 15:11:36 -0600
Message-ID: <1389561099-17181-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These 3 fixes should be applied as soon as possible. I understand that 3.13
will be released soon. As all 3 are marked for stable, inclusion in 3.14
will be satisfactory.

V2 - Patch 1 is unchanged, but 2 and 3 are fixed to remove any race conditions.

Larry


Larry Finger (3):
  b43: Fix lockdep splat
  b43: Fix unload oops if firmware is not available
  b43legacy: Fix unload oops if firmware is not available

 drivers/net/wireless/b43/b43.h        |  4 ++--
 drivers/net/wireless/b43/main.c       | 27 ++++++++++++++++-----------
 drivers/net/wireless/b43legacy/main.c |  1 +
 3 files changed, 19 insertions(+), 13 deletions(-)

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
