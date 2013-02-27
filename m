From: Chen Gang <gang.chen@asianux.com>
Subject: drivers/isdn: beautify code, delete 'break' after 'return'
Date: Wed, 27 Feb 2013 17:13:31 +0800
Message-ID: <512DCE3B.3050107@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:19676 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130Ab3B0JNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 04:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  delete 'break' statement after 'return' statement

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/isdn/i4l/isdn_tty.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index d8a7d83..925a7ed 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -3425,7 +3425,6 @@ isdn_tty_parse_at(modem_info *info)
 			p++;
 			isdn_tty_cmd_ATA(info);
 			return;
-			break;
 		case 'D':
 			/* D - Dial */
 			if (info->msr & UART_MSR_DCD)
-- 
1.7.7.6
