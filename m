From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Wed,  2 Nov 2016 17:35:12 +0200
Message-ID: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47728 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755794AbcKBPgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:36:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending RFC to get feedback for the following ethtool proposal:

In some cases such as virtual machines and multi functions (SR-IOV), the actual
bandwidth exposed for each machine is not accurately shown in ethtool.
Currently ethtool shows only physical port link speed.
In our case we would like to show the virtual port operational link speed
which in some cases is less than the physical port speed.

This will give users better visibility for the actual speed running on their device.

$ ethtool ens6
...
Speed: 50000Mb/s
Actual speed: 25000Mb/s

Gal Pressman (2):
  ethtool: Add get actual port speed support
  net/mlx5e: Add support for ethtool get actual speed callback

 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  7 +++++++
 include/linux/ethtool.h                              |  1 +
 include/uapi/linux/ethtool.h                         |  2 ++
 net/core/ethtool.c                                   | 20 ++++++++++++++++++++
 4 files changed, 30 insertions(+)

-- 
2.7.4
