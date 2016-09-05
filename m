From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 0/2] vxlan: add configuration check
Date: Mon,  5 Sep 2016 11:35:26 +0200
Message-ID: <cover.1473067954.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56128 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932192AbcIEJfs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 05:35:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mirror the vxlan configuration check recently added to the kernel.

While at this, I also converted open coded IPv6 address comparisons to the
standard macros.

Jiri Benc (2):
  tunnels: use macros for IPv6 address comparison
  vxlan: group address requires net device

 ip/ip6tunnel.c     |  8 ++++----
 ip/iplink_geneve.c |  6 +++---
 ip/iplink_vxlan.c  | 19 ++++++++++++-------
 3 files changed, 19 insertions(+), 14 deletions(-)

-- 
1.8.3.1
