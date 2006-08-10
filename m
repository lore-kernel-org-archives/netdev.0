From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 00/03]: Increase number of possible routing tables
Date: Fri, 11 Aug 2006 00:14:47 +0200 (MEST)
Message-ID: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26852 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750785AbWHJWOu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 18:14:50 -0400
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for a larger number of routing tables to iproute
and are needed for the patches doing the same for the kernel I just sent.
They apply on top of the "[IPROUTE]: Support IPv6 routing table filter" patch.

Please apply, thanks.


 include/linux/rtnetlink.h |    4 -
 include/rt_names.h        |    2 
 ip/ip_common.h            |    8 +++
 ip/iproute.c              |   63 ++++++++++++++++------------
 ip/iprule.c               |   14 +++++-
 lib/rt_names.c            |  100 ++++++++++++++++++++++++++++++++++------------
 6 files changed, 133 insertions(+), 58 deletions(-)

Patrick McHardy:
      [IPROUTE]: Preparation for 32 bit table IDs
      [IPROUTE]: Use hash for routing table name cache
      [IPROUTE]: Add support for larger number of routing tables
