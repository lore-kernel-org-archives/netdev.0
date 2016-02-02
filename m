From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 0/2] virtio_net: add ethtool get/set settings support
Date: Tue,  2 Feb 2016 15:33:38 +0100
Message-ID: <1454423620-2855-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33120 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755377AbcBBOdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:33:46 -0500
Received: by mail-wm0-f67.google.com with SMTP id r129so2711597wmr.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 06:33:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
Patch 1 adds ethtool speed/duplex validation functions which check if the
value is defined. Patch 2 adds support for ethtool (get|set)_settings and
uses the validation functions to check the user-supplied values.

v2: split in 2 patches to allow everyone to make use of the validation
functions and allow virtio_net devices to be half duplex

Cheers,
 Nik


Nikolay Aleksandrov (2):
  ethtool: add speed/duplex validation functions
  virtio_net: add ethtool support for set and get of settings

 drivers/net/virtio_net.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/ethtool.h | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+)

-- 
2.4.3
