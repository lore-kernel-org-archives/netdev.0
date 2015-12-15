From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2 0/3] improve lwtunnel route support
Date: Tue, 15 Dec 2015 16:48:24 +0100
Message-ID: <cover.1450193891.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862AbbLOPsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 10:48:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series try to improve the current route based
lwtunnel support in iproute2, namely adding support for the
COLLECT_METADATA flag in vxlan and gre link, and for ip6
encap type in lwtunnel.

Tunnel devices need to have the COLLECT_METADATA flag
set in order to be used for route based lwtunnel.

Paolo Abeni (3):
  vxlan: add support for collect metadata flag
  gre: add support for collect metadata flag
  lwtunnel: implement support for ip6 encap

 ip/iplink_vxlan.c     | 12 ++++++-
 ip/iproute_lwtunnel.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 ip/link_gre.c         | 11 +++++++
 3 files changed, 112 insertions(+), 2 deletions(-)

-- 
1.8.3.1
