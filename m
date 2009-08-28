From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 00/17] tg3: 5717 support part 1
Date: Fri, 28 Aug 2009 15:27:50 -0700
Message-ID: <1251585276.29660@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2416 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbZH2Wev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds two patches for the 5785 and starts support for the
5717 ASIC rev.  The 5717 ASIC rev is a new dual-port NetXtreme I server
controller family that supports MSIX, jumbo frames, TSS and RSS.  The
devices can operate with copper and / or serdes phys.  This patchset
gets the ball rolling by taking care of a few housekeeping items and
then preparing the napi and interrupt routines for multiple interrupt
vector support.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

