From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 iproute2 0/6] Add support for vrf keyword
Date: Mon, 27 Jun 2016 11:50:55 -0700
Message-ID: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35012 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbcF0SvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:51:09 -0400
Received: by mail-pa0-f43.google.com with SMTP id hl6so61420104pac.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:51:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the syntax for VRF related commands is rather kludgy and
inconsistent from one subcommand to another. This set adds support
for the VRF keyword to the link, address, neigh, and route commands
to improve the user experience listing data associated with vrfs,
modifying routes or doing a route lookup.

v2
- rebased to top of tree
- all checkpatch warnings are usage lines. The change in these
  patches is consistent with existing code for usage lines

David Ahern (6):
  ip vrf: Add name_is_vrf
  ip link/addr: Add support for vrf keyword
  ip neigh: Add support for keyword
  ip route: Change type mask to bitmask
  ip vrf: Add ipvrf_get_table
  ip route: Add support for vrf keyword

 ip/ip_common.h  |   3 ++
 ip/ipaddress.c  |  12 +++++-
 ip/iplink.c     |  15 ++++++-
 ip/iplink_vrf.c | 119 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/ipneigh.c    |  14 ++++++-
 ip/iproute.c    |  43 ++++++++++++++++----
 6 files changed, 195 insertions(+), 11 deletions(-)

-- 
2.1.4
