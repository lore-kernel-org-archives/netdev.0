From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v5 0/3] remove bridge mode BRIDGE_MODE_SWDEV
Date: Mon,  8 Dec 2014 14:04:18 -0800
Message-ID: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45198 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbaLHWEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:04:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

BRIDGE_MODE_SWDEV was introduced to indicate switchdev offloads
for bridging from user space (In other words to call into the hw switch
port driver directly). But user can use existing BRIDGE_FLAGS_SELF
to call into the hw switch port driver today. swdev mode is not required
anymore. So, this patch removes it.

v4 - v5
    incorporate comments
    - Define BRIDGE_MODE_UNDEF to handle cases where mode is not defined
    - reverse the order of patches
    - include patch comments in all patches

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (3):
  bridge: new mode flag to indicate mode 'undefined'
  rocker: remove swdev mode
  bridge: remove mode 'swdev'

 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 include/uapi/linux/if_bridge.h       |    2 +-
 net/core/rtnetlink.c                 |   10 ++++++++--
 3 files changed, 10 insertions(+), 20 deletions(-)

-- 
1.7.10.4
