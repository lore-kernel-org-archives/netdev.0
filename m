From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v5 0/2]  Adding downshift support to ethtool
Date: Thu, 24 Nov 2016 09:56:49 +0100
Message-ID: <1479977811-5603-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linville@tuxdriver.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0068.outbound.protection.outlook.com ([104.47.40.68]:4544
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934820AbcKXI5K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 03:57:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(downshift feature is applied in the net-next tree - d3c19c0a72)

This series adds support for downshift (using phy-tunables).

Downshifting can either be turned on/off, or it can be configured to a
specifc count. "count" is optional.

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
v5:
- re-sync ethtool.h from the net-next tree.


Allan W. Nielsen (1):
  ethtool-copy.h:sync with net-next

Raju Lakkaraju (1):
  Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
    downshift

 ethtool-copy.h |  21 +++++++--
 ethtool.8.in   |  40 ++++++++++++++++
 ethtool.c      | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 202 insertions(+), 3 deletions(-)

-- 
2.7.3
