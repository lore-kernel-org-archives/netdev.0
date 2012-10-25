From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 00/11] usbnet: usb_control_msg cleanup
Date: Thu, 25 Oct 2012 13:46:53 +0800
Message-ID: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:63538 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab2JYFrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 01:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set introduces 3 helpers for handling usb read, write
and write_async command, and replaces the low level's implemention
with the generic ones.

This patchset is a cleanup and about 300 lines code is saved.

Also, the patchset fixes problem of DMA on buffer embedded inside
one dynamic allocated buffer, and such usages can be found
in cdc-ncm, sierra_net, mcs7830 and asix drivers.

v2:
	- rebase on 3.7.0-rc2-next-20121025, only 01 and 03 changed

v1:
        - drop previous patch 12

 drivers/net/usb/asix_common.c |  117 ++++--------------------------------
 drivers/net/usb/cdc_ncm.c     |   85 ++++++++++----------------
 drivers/net/usb/dm9601.c      |  107 +++++----------------------------
 drivers/net/usb/int51x1.c     |   52 +---------------
 drivers/net/usb/mcs7830.c     |   85 ++------------------------
 drivers/net/usb/net1080.c     |  110 ++++++++++------------------------
 drivers/net/usb/plusb.c       |   11 ++--
 drivers/net/usb/sierra_net.c  |   45 ++++++--------
 drivers/net/usb/smsc75xx.c    |   39 +++++-------
 drivers/net/usb/smsc95xx.c    |  115 +++++++++--------------------------
 drivers/net/usb/usbnet.c      |  132 +++++++++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h    |    6 ++
 12 files changed, 298 insertions(+), 606 deletions(-)


Thanks,
--
Ming Lei
