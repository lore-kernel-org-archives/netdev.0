From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next V2 0/3] xen-netback: misc fixes
Date: Thu, 2 May 2013 11:43:56 +0100
Message-ID: <1367491439-27629-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <jbeulich@suse.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56579 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab3EBKoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 06:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes glitches spotted by Jan. Please see commit logs for details.

A third patch is added to have better names for different thresholds, suggested
by Ian Campbell.

Wei Liu (3):
  xen-netback: remove redundent parameter in netbk_count_requests
  xen-netback: avoid allocating variable size array on stack
  xen-netback: better names for thresholds

 drivers/net/xen-netback/netback.c |   69 +++++++++++++++++++++++--------------
 1 file changed, 44 insertions(+), 25 deletions(-)

-- 
1.7.10.4
