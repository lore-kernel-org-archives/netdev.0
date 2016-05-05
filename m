From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: l3mdev: Allow send on enslaved interface
Date: Wed,  4 May 2016 21:54:08 -0700
Message-ID: <1462424050-16084-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36332 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbcEEEy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:54:26 -0400
Received: by mail-pa0-f52.google.com with SMTP id bt5so31496822pac.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 21:54:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch preps for the second. The second is required for several use
cases such as ping on an interface and BFD that need to send packets on
a specific interface, including ones enslaved to a VRF device.

David Ahern (2):
  net: l3mdev: Move get_saddr and rt6_dst
  net: l3mdev: Allow send on enslaved interface

 drivers/net/vrf.c    |  2 ++
 include/net/l3mdev.h | 56 +++-----------------------------------------
 net/ipv4/route.c     |  4 ++++
 net/ipv6/route.c     |  2 +-
 net/l3mdev/l3mdev.c  | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 75 insertions(+), 54 deletions(-)

-- 
2.1.4
