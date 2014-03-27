From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net 0/3] xen-netback: fix rx slot estimation
Date: Thu, 27 Mar 2014 12:23:05 +0000
Message-ID: <1395922988-37702-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65121 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbaC0MXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:23:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sander Eikelenboom reported an issue with ring overflow netback in 3.14-rc3.
This turns outo be be because of a bug in the ring slot estimation code.
This patch series fixes the slot estimation, fixes the BUG_ON() that was
supposed to catch the issue that Sander ran into and also makes a small
fix to start_new_rx_buffer().
