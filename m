From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v4 0/2] Adding downshift support to ethtool
Date: Tue, 22 Nov 2016 21:32:15 +0100
Message-ID: <1479846737-18669-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0087.outbound.protection.outlook.com ([104.47.38.87]:26800
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751454AbcKVUcv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 15:32:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(downshift feature is applied in the net-next tree - d3c19c0a72)

This series adds support for downshift (using phy-tunables).

Downshifting can either be turned on/off, or it can be configured to a
specifc count.

"count" is optional.

Change set:
v1:
- Initial version of set/get phy tunable with downshift feature.
v2:
- (ethtool) Syntax is changed from "--set-phy-tunable downshift on|off|%d"
  to "--set-phy-tunable [downshift on|off [count N]]" - as requested by
  Andrew.
v3:
- Fixed Spelling in "ethtool-copy.h:sync with net" 
- Fixed "if send_ioctl() returns an error, print the error message and then
  still print th value of count".
v4:
- Fixing spelling in the example included in the commit message
- Improve the description in the man-page

Raju Lakkaraju (2):
  ethtool-copy.h:sync with net
  Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
    downshift

 ethtool-copy.h |  18 +++++++-
 ethtool.8.in   |  40 ++++++++++++++++
 ethtool.c      | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 201 insertions(+), 1 deletion(-)

-- 
2.7.3
