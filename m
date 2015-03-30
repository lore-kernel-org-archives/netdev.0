From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v3 0/4] mpls: Behaviour-changing improvements
Date: Mon, 30 Mar 2015 19:15:52 +0100
Message-ID: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41589 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752684AbbC3SRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:17:33 -0400
In-Reply-To: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series consists of several small changes to make it easier to
understand the code, along with security and RFC-compliance
changes. These are important to consider before userspace begins
relying on the previous behaviour.

V2:
  - Dropped PHP comment patch to avoid holding up the rest of the
    changes due to quibbling on nomenclature.
  - Corrected reference to RFC 3031 in commit message of patch
    2. Added reference to RFC 3031 s4.1.5 for PHP behaviour.
  - s/forwarding/input/ in patch 3.
  - Made MPT_IPV4 and MPT_IPV6 equal to 4 and 6 respectively in patch
    4, eliminating a switch on the version number as suggested by
    review comments. Added back references to RFCs, but moved them to
    mpls_payload_type enum declaration.
V1:
  - Updated to reference the correct RFC in the first patch.

Robert Shearman (4):
  mpls: Use definition for reserved label checks
  mpls: Differentiate implicit-null and unlabeled neighbours
  mpls: Per-device enabling of packet input
  mpls: Allow payload type to be associated with label routes

 Documentation/networking/mpls-sysctl.txt |   9 ++
 include/linux/netdevice.h                |   4 +
 net/mpls/af_mpls.c                       | 226 +++++++++++++++++++++++++------
 net/mpls/internal.h                      |   7 +
 4 files changed, 203 insertions(+), 43 deletions(-)

-- 
2.1.4
