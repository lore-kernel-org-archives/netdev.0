From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 0/6] Add support for vrf keyword
Date: Tue, 14 Jun 2016 13:59:26 -0700
Message-ID: <1465937972-25011-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34151 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbcFNU7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 16:59:40 -0400
Received: by mail-pa0-f49.google.com with SMTP id bz2so626679pad.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 13:59:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the syntax for VRF related commands is rather kludgy and
inconsistent from one subcommand to another. This set adds support
for the VRF keyword to the link, address, neigh, and route commands
to improve the user experience listing data associated with vrfs,
modifying routes or doing a route lookup.

David Ahern (6):
  ip vrf: Add name_is_vrf
  ip link/addr: Add support for vrf keyword
  ip neigh: Add support for keyword
  ip route: Change type mask to bitmask
  ip vrf: Add ipvrf_get_table
  ip route: Add support for vrf keyword

 ip/ip_common.h  |   3 ++
 ip/ipaddress.c  |  11 ++++++
 ip/iplink.c     |  15 ++++++-
 ip/iplink_vrf.c | 119 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/ipneigh.c    |  14 ++++++-
 ip/iproute.c    |  43 ++++++++++++++++----
 6 files changed, 195 insertions(+), 10 deletions(-)

-- 
2.1.4
