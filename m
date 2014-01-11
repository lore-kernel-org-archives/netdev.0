From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 0/3] Fixes for b43 and b43legacy
Date: Sat, 11 Jan 2014 13:48:31 -0600
Message-ID: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
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

Larry
 

Larry Finger (3):
  b43: Fix lockdep splat
  b43: Fix oops if firmware is not available
  b43legacy: Fix oops if firmware is not available

 drivers/net/wireless/b43/main.c       | 24 +++++++++++++++---------
 drivers/net/wireless/b43legacy/main.c |  5 +++--
 2 files changed, 18 insertions(+), 11 deletions(-)

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
