From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH v2 net-next 0/2] enic: Add adaptive coalescing interrupt support
Date: Tue, 20 May 2014 03:12:42 +0530
Message-ID: <1400535762-13318-1-git-send-email-_govind@gmx.com>
Cc: benve@cisco.com, neepatel@cisco.com, ssujith@cisco.com,
	_govind@gmx.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:61041 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbaESVoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 17:44:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for adaptive coalescing interrupt and updates 
enic Maintainers.

v1->v2:
	* Add commit log
	* do vnic_intr_coalescing_timer_set only while enabling intr
	* use ktime_get instead of hrtimer
	* make enic_set_rx_coal_setting return type void
	* change func name enic_apply_int_moderation to enic_calc_int_moderation

Govindarajulu Varadarajan (1):
  MAINTAINERS: Update enic maintainers

Sujith Sankar (1):
  enic: Add support for adaptive interrupt coalescing

 MAINTAINERS                                    |   3 +-
 drivers/net/ethernet/cisco/enic/enic.h         |  30 +++++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  61 +++++++++-
 drivers/net/ethernet/cisco/enic/enic_main.c    | 150 +++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_cq.h      |   9 ++
 5 files changed, 245 insertions(+), 8 deletions(-)

-- 
1.9.2
