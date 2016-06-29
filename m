From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3 iproute2 0/6] Add support for vrf keyword
Date: Wed, 29 Jun 2016 11:06:14 -0700
Message-ID: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33374 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbcF2SGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:06:40 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so19723628pat.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the syntax for VRF related commands is rather kludgy and
inconsistent from one subcommand to another. This set adds support
for the VRF keyword to the link, address, neigh, and route commands
to improve the user experience listing data associated with vrfs,
modifying routes or doing a route lookup.

v3
- addressed comments from Stephen
- added documentation updates to patches 2, 3 and 6

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

 ip/ip_common.h           |   3 ++
 ip/ipaddress.c           |  12 ++++-
 ip/iplink.c              |  15 +++++-
 ip/iplink_vrf.c          | 116 +++++++++++++++++++++++++++++++++++++++++++++++
 ip/ipneigh.c             |  14 +++++-
 ip/iproute.c             |  43 +++++++++++++++---
 man/man8/ip-address.8.in |   6 +++
 man/man8/ip-link.8.in    |  10 ++++
 man/man8/ip-neighbour.8  |   8 +++-
 man/man8/ip-route.8.in   |  19 +++++++-
 10 files changed, 233 insertions(+), 13 deletions(-)

-- 
2.1.4
