From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH 0/2] Add ethtool get_ringparam and set_ringparam to cadence
Date: Wed, 19 Oct 2016 09:56:56 -0500
Message-ID: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:43305 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S943414AbcJSO5I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 10:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are use cases like RT that would benefit from being able to tune the
macb rx/tx ring sizes. The ethtool set_ringparam function is the standard way
of doing so.

The first patch changes the hardcoded tx/rx ring sizes to variables that are
set to a hardcoded default.

The second patch implements the get_ringparam and set_ringparam fucntions.

Zach Brown (2):
  net: macb: Use variables with defaults for tx/rx ring sizes instead of
    hardcoded values
  net: macb: Add ethtool get_ringparam and set_ringparam functionality

 drivers/net/ethernet/cadence/macb.c | 173 +++++++++++++++++++++++++-----------
 drivers/net/ethernet/cadence/macb.h |   3 +
 2 files changed, 124 insertions(+), 52 deletions(-)
