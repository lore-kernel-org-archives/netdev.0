From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 0/2] cdc_ncm refactoring
Date: Tue,  2 Jun 2015 11:08:33 +0200
Message-ID: <1433236115-5594-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I changed my mind, and decided to try in following this new way.
This series splits the cdc_ncm_ndp function in two parts:
- one that finds NDP blocks already present in the SKB being sent out
- one that pushes new ones, starting from where the _find function left.

After this splitting it seems more easy to modify the location where the NDP is 
disposed.
What do you think about this?

>From now on, I need a little bit of help: I think we might work on the 
cdc_ncm_ndp16_push function, still I am open to any suggestion.

Let me know if you like this.
Enrico

Enrico Mioso (2):
  cdc_ncm: add the currently processed NDP frame to global driver data
  cdc_ncm: split the cdc_ncm_ndp funciton

 drivers/net/usb/cdc_ncm.c   | 30 +++++++++++++++++++++---------
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 22 insertions(+), 9 deletions(-)

-- 
2.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
