From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v3 0/2] vxlan: allow specifying multiple default destinations
Date: Wed, 29 May 2013 13:00:14 +0300
Message-ID: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog112.obsmtp.com ([74.125.245.92]:54481 "HELO
	na3sys010aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965107Ab3E2KAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 06:00:40 -0400
Received: by mail-ea0-f181.google.com with SMTP id a11so5197065eae.12
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 03:00:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These patches add ability to specify multiple default destinations to
vxlan. This ability is usefull in cases when multicast are disabled on
infrastructure level, for instance in public clouds.

v3 changes:
* make netlink interface for remote destinations management more
  generic and extend vxlan_validate to handle newly added atttributes.
  (as proposed by Thomas Graf)

v2 changes:
* rebased on current net-next
* flush default destinations list at dellink as per Atzm Watanabe comment
* support only IPv4

Mike Rapoport (2):
  vxlan: introduce vxlan_rdst_append
  vxlan: allow specifying multiple default destinations

 drivers/net/vxlan.c          | 252 ++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_link.h |  17 +++
 2 files changed, 265 insertions(+), 4 deletions(-)

-- 
1.8.1.5
