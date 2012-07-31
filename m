From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mac80211: use eth_broadcast_addr
Date: Tue, 31 Jul 2012 08:46:09 -0700
Message-ID: <1343749569.6383.2.camel@joe2Laptop>
References: <1343744471-5910-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34858 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751133Ab2GaPqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 11:46:11 -0400
In-Reply-To: <1343744471-5910-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-31 at 16:21 +0200, Johannes Berg wrote:
> Instead of memset().

Maybe just do them all?

git ls-files net drivers/net |
xargs perl -p -i -e 's/\bmemset\s*\(\s*([^,]+),\s*(?i:0xff|255)\s*\,\s*(ETH_ALEN|6)\s*\)/eth_broadcast_addr\(\1\)/g'
