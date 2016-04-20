From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next resubmit PATCH v2 0/3] Feature tweaks/fixes follow-up to
 GSO partial patches
Date: Wed, 20 Apr 2016 16:50:41 -0400
Message-ID: <20160420204900.4029.42938.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36508 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcDTUuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:50:52 -0400
Received: by mail-pf0-f171.google.com with SMTP id e128so21755698pfe.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 13:50:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a set of minor fix-ups and tweaks following the GSO
partial and TSO with IPv4 ID mangling patches.  It mostly is just meant to
make certain that if we have GSO partial support at the device we can make
use of it from the far end of the tunnel.

I submitted this earlier today but it was set as RFC in patchwork.  This is
a submission for net-next and not an RFC so I am resubmitting.

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
