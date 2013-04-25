From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next 0/2] vxlan: allow specifying multiple default destinations
Date: Thu, 25 Apr 2013 14:03:47 +0300
Message-ID: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:59385 "HELO
	na3sys010aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755522Ab3DYLEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 07:04:05 -0400
Received: by mail-bk0-f71.google.com with SMTP id jc3so3559956bkc.2
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 04:04:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These patches add ability to specify multiple default destinations to
vxlan. This ability is usefull in cases when multicast are disabled on
infrastructure level, for instance in public clouds.

The patches are based on top of Cong's changes for IPv6 support.

Mike Rapoport (2):
  vxlan: introduce vxlan_rdst_append
  vxlan: allow specifying multiple default destinations

 drivers/net/vxlan.c          | 190 ++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_link.h |  14 ++++
 2 files changed, 200 insertions(+), 4 deletions(-)

-- 
1.8.1.5
