From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 0/3 for 3.18] rtlwifi: rtl8192ce: Patches to fix the regression reported in Bug #88951
Date: Fri, 28 Nov 2014 10:41:13 -0600
Message-ID: <1417192876-12101-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These three patches are needed to fix a regression in kernel 3.18 that is
reported in Bug #88951. I hate to be the guy with the last-minute fixes;
however, this regression reminded me of the children's game called Whack-a-mole.
Whenever I thought that I had found the problem, the bug popped up elsewhere.
Finally I am coinfident that I have fixed the problem.

Fortunately, the patches are all fairly small, and they are self-contained within
a single driver. There are unlikely to be any unfavorable side effects.

If it is not possible to get these patches into 3.18, then mark them to be
backported to stable (3.18 only). That way they will be available in 3.18.1.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Reported-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Tested-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

Larry Finger (3):
  rtlwifi: rtl8192ce: Fix editing error that causes silent memory
    corruption
  rtlwifi: rtl8192ce: Fix kernel crashes due to missing callback entry
  rtlwifi: rtl8192ce: Fix missing interrupt ready flag

 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  3 +++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 24 ++++++++++++++++++++----
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h |  2 ++
 4 files changed, 27 insertions(+), 5 deletions(-)

-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
