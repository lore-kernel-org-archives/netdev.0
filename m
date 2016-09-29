From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/2] openvswitch: mpls fix and clean up
Date: Thu, 29 Sep 2016 21:19:46 +0200
Message-ID: <cover.1475176437.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60072 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754801AbcI2TUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 15:20:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to the new mpls skb layout the last remaining place in openvswitch,
forgotten on the mpls GSO rework. The GSO rework also allows for some nice
cleanup in the second patch.

Jiri Benc (2):
  openvswitch: mpls: set network header correctly on key extract
  openvswitch: remove skb_mpls_header

 include/net/mpls.h        | 11 -----------
 net/openvswitch/actions.c | 10 +++++-----
 net/openvswitch/flow.c    | 11 +++--------
 3 files changed, 8 insertions(+), 24 deletions(-)

-- 
1.8.3.1
