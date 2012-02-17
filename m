From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/4] RX NFC cleanup
Date: Fri, 17 Feb 2012 20:54:02 +0000
Message-ID: <1329512042.2822.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15413 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751533Ab2BQUyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:54:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm about to push these changes out, along with one fix received from
Intel.

Ben.

Ben Hutchings (4):
  Move '--flash' down the list of options
  Merge RX NFC options
  ethtool.8: Don't mention the 'clear rule' action for NFC rules
  ethtool.8: Improve description of RX NFC options

 ethtool.8.in   |  165 +++++++++++++++++++++++++---------------------------
 ethtool.c      |  178 ++++++++++++++++++++++++--------------------------------
 test-cmdline.c |   52 +++++++++--------
 3 files changed, 182 insertions(+), 213 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
