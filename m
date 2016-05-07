From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] net: l3mdev: Allow send on enslaved interface
Date: Sat,  7 May 2016 16:48:58 -0700
Message-ID: <1462664940-26678-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33867 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcEGXtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 19:49:08 -0400
Received: by mail-pa0-f41.google.com with SMTP id r5so61074882pag.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 16:49:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch preps for the second. The second is required for several use
cases such as ping on an interface and BFD that need to send packets on
a specific interface, including ones enslaved to a VRF device.

v2
- fixed brackets on both patches per comment from DaveM

David Ahern (2):
  net: l3mdev: Move get_saddr and rt6_dst
  net: l3mdev: Allow send on enslaved interface

 drivers/net/vrf.c    |  2 ++
 include/net/l3mdev.h | 56 +++-------------------------------------------
 net/ipv4/route.c     |  4 ++++
 net/ipv6/route.c     |  2 +-
 net/l3mdev/l3mdev.c  | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 73 insertions(+), 54 deletions(-)

-- 
2.1.4
