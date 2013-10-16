From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v5 0/5] xen-netback: IPv6 offload support
Date: Wed, 16 Oct 2013 17:50:27 +0100
Message-ID: <1381942232-26268-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:57659 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761113Ab3JPQug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:50:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for checksum and large packet offloads into
xen-netback.
Testing has mainly been done using the Microsoft network hardware
certification suite running in Server 2008R2 VMs with Citrix PV frontends.

v2:
- Fixed Wei's email address in Cc lines

v3:
- Responded to Wei's comments:
 - netif.h now updated with comments and a definition of
   XEN_NETIF_GSO_TYPE_NONE.
 - limited number of pullups
- Responded to Annie's comments:
 - New GSO_BIT macro

v4:
- Responded to more of Wei's comments
- Remove parsing of IPv6 fragment header and added warning

v5:
- Added comment concerning the value chosen for PKT_PROT_LEN
- Dropped deprecation of feature-no-csum-offload
