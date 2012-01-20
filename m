From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Add unix_diag.h to kernel userspace headers
Date: Fri, 20 Jan 2012 12:41:09 -0800
Message-ID: <20120120124109.478f65e3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39345 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754325Ab2ATUlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 15:41:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to use provide unix domain diag information in iproute2 means that
an additional header file has to be added to the kbuild header export list.
This ensures that any changes to the header file get picked up in future merges.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch for -net (ie 3.3) 

--- a/include/linux/Kbuild	2012-01-10 10:56:59.659188065 -0800
+++ b/include/linux/Kbuild	2012-01-20 12:36:53.518655336 -0800
@@ -375,6 +375,7 @@ header-y += uio.h
 header-y += ultrasound.h
 header-y += un.h
 header-y += unistd.h
+header-y += unix_diag.h
 header-y += usbdevice_fs.h
 header-y += utime.h
 header-y += utsname.h
