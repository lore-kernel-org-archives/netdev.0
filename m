From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 0/3] openvswitch: mpls fix and clean up
Date: Fri, 30 Sep 2016 19:08:04 +0200
Message-ID: <cover.1475255100.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36684 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932539AbcI3RJD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to the new mpls skb layout the last remaining place in openvswitch,
forgotten on the mpls GSO rework. The GSO rework also allows for some
cleanup in the third patch.

Jiri Benc (3):
  openvswitch: mpls: set network header correctly on key extract
  mpls: move mpls_hdr to a common location
  openvswitch: use mpls_hdr

 include/net/mpls.h        | 15 ++++++---------
 net/mpls/internal.h       | 10 +---------
 net/openvswitch/actions.c | 24 ++++++++++++------------
 net/openvswitch/flow.c    | 11 +++--------
 4 files changed, 22 insertions(+), 38 deletions(-)

-- 
1.8.3.1
