From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 0/3] Remove inet_lro remnants
Date: Fri, 16 Nov 2012 22:40:35 +0000
Message-ID: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61860 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723Ab2KPWki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 17:40:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric's comments on LRO/GRO conversion prompted me to check what was
still using inet_lro.  Not very many drivers, but there are a few
unnecessary references outside the code.

Ben.

Ben Hutchings (3):
  mlx4_en: Remove remnants of LRO support
  ehea: Remove remnants of LRO support
  net: Remove bogus dependencies on INET

 drivers/net/ethernet/chelsio/Kconfig         |    4 ++--
 drivers/net/ethernet/cisco/Kconfig           |    2 +-
 drivers/net/ethernet/cisco/enic/Kconfig      |    2 +-
 drivers/net/ethernet/emulex/Kconfig          |    2 +-
 drivers/net/ethernet/emulex/benet/Kconfig    |    2 +-
 drivers/net/ethernet/ibm/Kconfig             |    5 ++---
 drivers/net/ethernet/ibm/ehea/ehea_main.c    |    2 +-
 drivers/net/ethernet/intel/Kconfig           |    2 +-
 drivers/net/ethernet/mellanox/Kconfig        |    2 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig   |    3 +--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    9 +++------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   17 -----------------
 drivers/net/ethernet/neterion/Kconfig        |    2 +-
 drivers/net/ethernet/sfc/Kconfig             |    2 +-
 14 files changed, 17 insertions(+), 39 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
