From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 0/2] remove bridge BRIDGE_MODE_SWDEV
Date: Sat,  6 Dec 2014 22:54:25 -0800
Message-ID: <1417935267-6000-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45720 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbaLGGyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 01:54:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (2):
  bridge: remove mode 'swdev'
  rocker: remove swdev mode

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 include/linux/rtnetlink.h            |    2 +-
 include/uapi/linux/if_bridge.h       |    1 -
 net/core/rtnetlink.c                 |   12 +++++++++---
 4 files changed, 11 insertions(+), 22 deletions(-)

-- 
1.7.10.4
