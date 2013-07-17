From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH net-next 0/2] pch_gbe: Minow fix and MinnowBoard support
Date: Wed, 17 Jul 2013 13:10:41 -0700
Message-ID: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11129 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378Ab3GQUKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 16:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the MinnowBoard in the pch_gbe driver. This was originally sent
to LKML as part of the MinnowBoard support series. That is now partially merged
and this version of the patch has been isolated from those changes and is now
completely self-contained.

Since the previous version:
    Whitespace cleanup
    Remove trailing period in messages
    Comment formatting (added a colon)
    Use devm_gpio_request_one
    Fix missing adapter->pdata NULL check in PHY
    Use netdev style comment blocks
