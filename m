From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v3 0/2] virtio_net: add ethtool get/set settings support
Date: Tue,  2 Feb 2016 17:21:25 +0100
Message-ID: <1454430087-2062-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35712 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992AbcBBQVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:21:35 -0500
Received: by mail-wm0-f68.google.com with SMTP id l66so3149423wml.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:21:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
Patch 1 adds ethtool speed/duplex validation functions which check if the
value is defined. Patch 2 adds support for ethtool (get|set)_settings and
uses the validation functions to check the user-supplied values.

v2: split in 2 patches to allow everyone to make use of the validation
functions and allow virtio_net devices to be half duplex
v3: added a check to return error if the user tries to change anything else
besides duplex/speed as per Michael's comment

Cheers,
 Nik


Nikolay Aleksandrov (2):
  ethtool: add speed/duplex validation functions
  virtio_net: add ethtool support for set and get of settings

 drivers/net/virtio_net.c     | 58 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/ethtool.h | 34 ++++++++++++++++++++++++++
 2 files changed, 92 insertions(+)

-- 
2.4.3
