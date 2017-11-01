From: Parvi Kaustubhi <pkaustub@cisco.com>
Subject: [PATCH net-next v2 0/3] enic: Additional ethtool support
Date: Wed,  1 Nov 2017 08:44:45 -0700
Message-ID: <1509551088-29301-1-git-send-email-pkaustub@cisco.com>
Cc: gvaradar@cisco.com, benve@cisco.com,
        Parvi Kaustubhi <pkaustub@cisco.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-1.cisco.com ([173.37.142.88]:45600 "EHLO
        alln-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdKAPpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 11:45:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set allows the user to show or modify rx/tx ring sizes using
ethtool.

v2:
- remove unused variable to fix build warning.
- update list of maintainers for cisco vic ethernet nic driver.

Parvi Kaustubhi (3):
  enic: reset fetch index
  enic: Add support for 'ethtool -g/-G'
  MAINTAINERS: update MAINTAINERS for cisco vic

 MAINTAINERS                                    |  2 +-
 drivers/net/ethernet/cisco/enic/enic.h         |  2 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 77 ++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_rq.c      | 16 +-----
 4 files changed, 81 insertions(+), 16 deletions(-)

-- 
1.8.3.1
