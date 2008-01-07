From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/3] ethtool: correct man page for advertise mask value of
	10gig
Date: Mon, 07 Jan 2008 09:36:16 -0800
Message-ID: <20080107173616.8429.92551.stgit@localhost.localdomain>
References: <20080107173602.8429.56354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39030 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754835AbYAGRgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 12:36:17 -0500
In-Reply-To: <20080107173602.8429.56354.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10 gigabit is defined as 0x1000 in the advertise mask. The man
page mistakenly lists 0x800.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool.8 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index af51056..cc6a46e 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -362,7 +362,7 @@ a hexidecimal value using one or a combination of the following values:
 .TP 3
 .BR "0x8000" "   2500 Full" "(not supported by IEEE standards)"
 .TP 3
-.BR "0x800" "    10000 Full"
+.BR "0x1000" "   10000 Full"
 .TP 3
 .BR "0x03F" "    Auto"
 .PD

