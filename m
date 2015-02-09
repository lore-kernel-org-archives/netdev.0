From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/3] Add support in ethtool to get expansion ROM version
Date: Mon,  9 Feb 2015 12:07:28 +0530
Message-ID: <1423463851-19073-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17947 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753229AbbBIGbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 01:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series adds support to get expansion ROM version via ethtool getdrvinfo.
PATCH 1/3 ("ethtool: rename reserved1 memeber in ethtool_drvinfo for expansion
    ROM version") is created against net-next tree.
PATCH 2/3 ("cxgb4: Add support in cxgb4 to get expansion rom version via
ethtool") is created against net-next tree.
PATCH 3/3 ("ethtool: Add support to get expansion ROM version in ethtool
getdrvinfo") is created against ethtool tree.

We have included all the maintainers of respective trees. Kindly review the
change and let us know in case of any review comments.

Thanks

V2: Use MACRO instead of hardcoded value for EROM version string len. Based on
review comment by David Miller.

Hariprasad Shenai (3):
  ethtool: rename reserved1 memeber in ethtool_drvinfo for expansion
    ROM version
  cxgb4: Add support in cxgb4 to get expansion rom version via ethtool
  ethtool: Add support to get expansion ROM version in ethtool getdrvinfo

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    9 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   37 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    8 +++++
 include/uapi/linux/ethtool.h                    |    4 ++-
 5 files changed, 58 insertions(+), 1 deletions(-)
---
 ethtool-copy.h |    4 +++-
 ethtool.c      |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)
