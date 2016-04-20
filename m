From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 0/3] Feature tweaks/fixes follow-up to GSO
 partial patches
Date: Wed, 20 Apr 2016 10:49:00 -0400
Message-ID: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36766 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbcDTOtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:49:11 -0400
Received: by mail-pa0-f52.google.com with SMTP id er2so18536094pad.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:49:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a set of minor fix-ups and tweaks following the GSO
partial and TSO with IPv4 ID mangling patches.  It mostly is just meant to
make certain that if we have GSO partial support at the device we can make
use of it from the far end of the tunnel.

v2: Added cover page which was forgotten with first submission.
    Added patch that enables TSOv4 IP ID mangling w/ tunnels and/or VLANs.

---

Alexander Duyck (3):
      netdev_features: Fold NETIF_F_ALL_TSO into NETIF_F_GSO_SOFTWARE
      veth: Update features to include all tunnel GSO types
      net: Add support for IP ID mangling TSO in cases that require encapsulation


 drivers/net/veth.c              |    7 +++----
 include/linux/netdev_features.h |    8 +++-----
 net/core/dev.c                  |   11 +++++++++++
 3 files changed, 17 insertions(+), 9 deletions(-)
