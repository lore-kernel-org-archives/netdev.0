From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 0/2] USBNET: max rx/tx qlen change
Date: Thu, 25 Jul 2013 13:47:52 +0800
Message-ID: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:34195 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab3GYFsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 01:48:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There are two patches on computing max rx/tx qlen, and fix one
performance problem on USB3 NIC.

 drivers/net/usb/asix_devices.c |    3 +++
 drivers/net/usb/ax88179_178a.c |    3 +++
 drivers/net/usb/usbnet.c       |   54 ++++++++++++++++++++++++++++++++++------
 include/linux/usb/usbnet.h     |    3 +++
 4 files changed, 55 insertions(+), 8 deletions(-)


Thanks,
--
Ming Lei
