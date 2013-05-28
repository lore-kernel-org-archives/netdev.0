From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v2 0/2] vxlan: allow specifying multiple default destinations
Date: Tue, 28 May 2013 11:31:16 +0300
Message-ID: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:44381 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933515Ab3E1Ib3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:31:29 -0400
Received: by mail-ea0-f175.google.com with SMTP id h10so4348921eaj.6
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:31:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These patches add ability to specify multiple default destinations to
vxlan. This ability is usefull in cases when multicast are disabled on
infrastructure level, for instance in public clouds.

v2 changes:
* rebased on current net-next
* flush default destinations list at dellink as per Atzm Watanabe comment
* support only IPv4

Mike Rapoport (2):
  vxlan: introduce vxlan_rdst_append
  vxlan: allow specifying multiple default destinations

 drivers/net/vxlan.c          | 164 +++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  14 ++++
 2 files changed, 174 insertions(+), 4 deletions(-)

-- 
1.8.1.5
