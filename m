From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH 4/6] d80211: add IEEE802.11e/WMM Traffic Stream (TS)
	Management support
Date: Mon, 18 Dec 2006 17:19:12 +0800
Message-ID: <1166433552.10342.44.camel@debian.sh.intel.com>
References: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B7@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43149 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604AbWLRJV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:21:57 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B7@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 21:45 -0800, Simon Barber wrote:
> This policing of media time must be done in the qdisc - and made to
> work
> per DA (Destination Address) - in order that AP mode will work as well
> as STA mode. In addition the count of used time should be updated
> AFTER
> the frame has been sent, not before, since the number of retries done
> cannot be taken into account before. These MUST be counted.
> 
> The API to the qdisc should be via TC - not cfg80211 or other. 

This is a good idea, but I have to think it more.

AFAIK, tc works on the host side. For the TS management case, how about
user makes a taffic stream request but the AP refuses it (or allowes the
request but the medium_time is changed), there has to be a way for tc to
get this information.

Thanks,
-yi
