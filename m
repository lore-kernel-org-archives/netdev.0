From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v3 0/2] Adding downshift support to ethtool
Date: Thu, 17 Nov 2016 13:07:58 +0100
Message-ID: <1479384480-31201-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0055.outbound.protection.outlook.com ([104.47.40.55]:20256
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941537AbcKQRlI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:41:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

(This is a re-post of the v3 patch set with a new cover letter - I was not
aware that the cover letters was used as commit comments in merge commits).

This patch implements for set/get downshifting.

Downshifting can either be turned on/off, or it can be configured to a
specifc count.

"count" is optional.

Tested on Beaglebone Black with VSC 8531 PHY.

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

Raju Lakkaraju (2):
  ethtool-copy.h:sync with net
  Ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY
    downshift

 ethtool-copy.h |  18 +++++++-
 ethtool.8.in   |  39 ++++++++++++++++
 ethtool.c      | 144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 200 insertions(+), 1 deletion(-)

-- 
2.7.4
