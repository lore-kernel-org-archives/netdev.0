From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net v2 0/3] r8152 bug fixes
Date: Wed, 30 Oct 2013 15:13:37 +0800
Message-ID: <1383117220-893-1-git-send-email-hayeswang@realtek.com>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383033377-1178-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I have update the commit messages. I hope they are clear enough.

I remove the stop/wake tx queue from the second patch first, until
I find a way to determine which value is suitable for TX_QLEN.

Hayes Wang (3):
  r8152: fix tx/rx memory overflow
  r8152: modify the tx flow
  r8152: fix incorrect type in assignment

 drivers/net/usb/r8152.c | 94 +++++++++++++++----------------------------------
 1 file changed, 29 insertions(+), 65 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
