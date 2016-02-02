From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/5] vxlan: cleanup headers and tx path
Date: Tue,  2 Feb 2016 11:13:20 +0100
Message-ID: <cover.1454407418.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404AbcBBKNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:13:50 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 16CCFC00124A
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 10:13:50 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-27.brq.redhat.com [10.40.204.27])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12ADmYe027928
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 05:13:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is first part of vxlan cleanup. It makes vxlan.h better organized and
removes code duplication in the tx path. There's no change in functionality.

This is in preparation for VXLAN-GPE support. Other sets will follow with
cleanup of rx path, modifications of vxlan interface setup and
cleanup/modification of fdb handling. The goal of these patchsets is to
consolidate VXLAN extension handling (right now it's scattered all around
the code) and allow vxlan to operate in L3 mode (i.e. without inner Ethernet
headers).

The full picture (all 30 patches) can be seen at:
https://github.com/jbenc/linux-vxlan/commits/master

Jiri Benc (5):
  vxlan: cleanup types
  vxlan: remove duplicated macros
  vxlan: restructure vxlan.h definitions
  vxlan: consolidate output route calculation
  vxlan: consolidate vxlan_xmit_skb and vxlan6_xmit_skb

 drivers/net/vxlan.c | 216 ++++++++++++++++------------------------------------
 include/net/vxlan.h | 115 ++++++++++++++++------------
 2 files changed, 132 insertions(+), 199 deletions(-)

-- 
1.8.3.1
