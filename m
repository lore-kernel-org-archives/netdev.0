From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.30] WiMAX pull request
Date: Fri, 22 May 2009 01:29:40 -0700
Message-ID: <cover.1242980768.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:39132 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753147AbZEVIaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 04:30:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull contains a single patch (bigger than I'd like) that fixes a
device reset, breaking the connection.

This caused by asking the device to auto-suspend (go into USB power
saving) in a bad moment. System suspend/hibernate are not affected.

-- 

The following changes since commit 4f72427998b105392e60bae7a6798a0c96fe4f0a:
  Jean-Mickael Guerin (1):
        IPv6: set RTPROT_KERNEL to initial route

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.30.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (1):
      wimax/i2400m: usb: fix device reset on autosuspend while not yet idle

 drivers/net/wimax/i2400m/usb.c |   35 ++++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 5 deletions(-)
