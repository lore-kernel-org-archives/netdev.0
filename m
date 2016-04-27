From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 0/2] ip link gre: fix external mode handling
Date: Wed, 27 Apr 2016 16:11:12 +0200
Message-ID: <cover.1461766016.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pravin Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbcD0OLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 10:11:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix two bugs with handling of the 'external' keyword for GRE.

Jiri Benc (2):
  ip link gre: create interfaces in external mode correctly
  ip link gre: print only relevant info in external mode

 ip/link_gre.c | 43 +++++++++++++++++++++++++------------------
 1 file changed, 25 insertions(+), 18 deletions(-)

-- 
1.8.3.1
