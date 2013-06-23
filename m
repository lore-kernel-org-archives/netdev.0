From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v4 0/2] vxlan: allow specifying multiple default destinations
Date: Sun, 23 Jun 2013 19:22:21 +0300
Message-ID: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:45016 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751478Ab3FWQWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:22:31 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so5500581eae.38
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:22:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Apparently, in my first send attempt I've misspeled netdev mailing address.
Sorry for the noise.

These patches add ability to specify multiple default destinations to
vxlan. This ability is usefull in cases when multicast are disabled on
infrastructure level, for instance in public clouds.

v4 changes:
* rebased on Stephen Hemminger vxlan-next tree
* updates to netlink interface according to Thomas Graf comments

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

 drivers/net/vxlan.c          | 282 +++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  17 +++
 2 files changed, 286 insertions(+), 13 deletions(-)

-- 
1.8.1.5
