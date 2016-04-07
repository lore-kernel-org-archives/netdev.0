From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 0/4] vxlan: add VXLAN-GPE support
Date: Thu,  7 Apr 2016 14:36:25 +0200
Message-ID: <cover.1460032274.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633AbcDGMhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 08:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a couple of refinements to the 'external' keyword and
adds support for configuring VXLAN-GPE interfaces.

The VXLAN-GPE support was recently merged to net-next.

The first patch is not intended to be applied directly but I still include
it in order for this patchset to be compilable and testable by those
interested.

Jiri Benc (4):
  if_link.h: rebase to the kernel
  vxlan: 'external' implies 'nolearning'
  ip-link.8: document "external" flag for vxlan
  vxlan: add support for VXLAN-GPE

 include/linux/if_link.h |  1 +
 ip/iplink_vxlan.c       | 14 ++++++++++++--
 man/man8/ip-link.8.in   | 17 +++++++++++++++++
 3 files changed, 30 insertions(+), 2 deletions(-)

-- 
1.8.3.1
