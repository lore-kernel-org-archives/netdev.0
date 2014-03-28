From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v3 0/3] xen-netback: fix rx slot estimation
Date: Fri, 28 Mar 2014 11:39:04 +0000
Message-ID: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64663 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaC1LjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 07:39:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sander Eikelenboom reported an issue with ring overflow in netback in
3.14-rc3. This turns outo be be because of a bug in the ring slot estimation
code. This patch series fixes the slot estimation, fixes the BUG_ON() that
was supposed to catch the issue that Sander ran into and also makes a small
fix to start_new_rx_buffer().

v3:
 - Added a cap of MAX_SKB_FRAGS to estimate in patch #2

v2:
 - Added BUG_ON() to patch #1
 - Added more explanation to patch #3
