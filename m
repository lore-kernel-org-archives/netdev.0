From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/2] virtio_net: better ethtool setting validation
Date: Sun,  7 Feb 2016 21:52:22 +0100
Message-ID: <1454878344-21730-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36834 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbcBGUw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 15:52:29 -0500
Received: by mail-wm0-f67.google.com with SMTP id 128so12578307wmz.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 12:52:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This small set is a follow-up for the recent patches that added ethtool
get/set settings. Patch 1 changes the speed validation routine to check
if the speed is between 0 and INT_MAX (or SPEED_UNKNOWN) and patch 2 adds
port validation to virtio_net and better validation comment.

This set is on top of Michael's patch which explains that speeds from 0
to INT_MAX are valid:
http://patchwork.ozlabs.org/patch/578911/

Cheers,
 Nik

Nikolay Aleksandrov (2):
  ethtool: make validate_speed accept all speeds between 0 and INT_MAX
  virtio_net: validate ethtool port setting and explain the user
    validation

 drivers/net/virtio_net.c     |  6 ++++--
 include/uapi/linux/ethtool.h | 19 +------------------
 2 files changed, 5 insertions(+), 20 deletions(-)

-- 
2.4.3
