From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2 v2 0/3] improve lwtunnel route support
Date: Wed, 16 Dec 2015 13:22:25 +0100
Message-ID: <cover.1450267709.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933781AbbLPMWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 07:22:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series try to improve the current route based
lwtunnel support in iproute2, namely adding support for the
COLLECT_METADATA flag in vxlan and gre link, and for ip6
encap type in lwtunnel.

Tunnel devices need to have the COLLECT_METADATA flag
set in order to be used for route based lwtunnel.

Changes from V1:
- the COLLECT_METADATA flag is now controlled via the 'external' keyword
- 'vni' and 'external' arguments are mutually exclusive for the vxlan link

Paolo Abeni (3):
  vxlan: add support for collect metadata flag
  gre: add support for collect metadata flag
  lwtunnel: implement support for ip6 encap

 ip/iplink_vxlan.c     | 19 +++++++++--
 ip/iproute_lwtunnel.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 ip/link_gre.c         | 11 +++++++
 3 files changed, 118 insertions(+), 3 deletions(-)

-- 
1.8.3.1
