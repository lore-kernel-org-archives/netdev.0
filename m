From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/4] ethtool.8: Don't mention the 'clear rule'
 action for NFC rules
Date: Fri, 17 Feb 2012 20:55:16 +0000
Message-ID: <1329512116.2822.7.camel@bwh-desktop>
References: <1329512042.2822.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15491 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754469Ab2BQUzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:55:19 -0500
In-Reply-To: <1329512042.2822.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sfc driver implemented a 'clear rule' action as a means to delete
a rule through the n-tuple API.  This action is not valid or useful in
the RX NFC API and it's probably confusing to mention it at all.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 6f0b246..4c46096 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -717,7 +717,6 @@ Specifies the Rx queue to send packets to, or some other action.
 .TS
 nokeep;
 lB	l.
--2	Clear the filter
 -1	Drop the matched flow
 0 or higher	Rx queue to route the flow
 .TE
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
