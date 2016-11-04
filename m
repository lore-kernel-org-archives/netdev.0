From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 0/2] Adding downshift support to ethtool
Date: Fri, 4 Nov 2016 11:36:43 +0100
Message-ID: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0081.outbound.protection.outlook.com ([104.47.40.81]:47447
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761081AbcKDKhA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch implements for set/get downshifting.

Downshifting can either be turned on/off, or it can be configured to a
specifc count.

If no "count" are provided, then it is up to the individual PHY driver to
configure a default count.

Best regards
Allan and Raju

Allan W. Nielsen (1):
  ethtool-copy.h:sync with net

Raju Lakkaraju (1):
  Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
    downshift

 ethtool-copy.h | 34 ++++++++++++++--------
 ethtool.8.in   | 27 +++++++++++++++++
 ethtool.c      | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 141 insertions(+), 12 deletions(-)

-- 
2.7.3
