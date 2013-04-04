From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] Mellanox Core and Ethernet driver updates 2013-04-04
Date: Thu,  4 Apr 2013 17:26:11 +0300
Message-ID: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:60498 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761533Ab3DDO0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:26:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a batch of mlx4 driver updates for 3.10, mostly DCB related. 

Series done against the net-next tree as of commit a210576c "Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"

Or.

Or Gerlitz (2):
  net/mlx4_core: Added proper description for two device capabilities
  net/mlx4_en: Enable DCB ETS ops only when supported by the firmware

Sagi Grimberg (1):
  net/mlx4_en: Enable open-lldp DCB support

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   42 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 ++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    4 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    5 ++-
 include/linux/mlx4/device.h                    |    1 +
 5 files changed, 59 insertions(+), 5 deletions(-)
