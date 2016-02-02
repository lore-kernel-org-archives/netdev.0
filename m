From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v4 0/2] virtio_net: add ethtool get/set settings support
Date: Wed,  3 Feb 2016 00:36:35 +0100
Message-ID: <1454456197-7826-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34521 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbcBBXgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 18:36:43 -0500
Received: by mail-wm0-f65.google.com with SMTP id p63so4694833wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 15:36:42 -0800 (PST)
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
v4: Set port type to PORT_OTHER

Cheers,
 Nik

Nikolay Aleksandrov (2):
  ethtool: add speed/duplex validation functions
  virtio_net: add ethtool support for set and get of settings

 drivers/net/virtio_net.c     | 59 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/ethtool.h | 34 +++++++++++++++++++++++++
 2 files changed, 93 insertions(+)

-- 
2.4.3
