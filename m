From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Mon, 18 Dec 2006 17:18:53 +0800
Message-ID: <1166433533.10342.42.camel@debian.sh.intel.com>
References: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B4@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29570 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604AbWLRJVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:21:44 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B4@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 21:35 -0800, Simon Barber wrote:
> This is all part of the client MLME - it would be much better to add
> this functionality to wpa_supplicant, rather than adding it to the
> kernel. Nothing here needs to be in the kernel for any reason.

Theoretically, the whole network stack can be put into userspace. But we
gain performance and userspace tool independency from implementing it in
the kernel. Currently d80211 handles beacon, associate response and
other MLMEs, I see no reason why they need to be in the kernel according
to your point.

IMHO, for the MLME handling, if it involves policy or decision making
from the user, it should be done by the userspace, otherwise we
implement it in the kernel for better performance and userspace tool
independency.

Thanks,
-yi

> The client MLME functions that are in the kernel were put in there for
> test and debugging convenience only - the right client MLME to use is
> the one in wpa_supplicant. Especially with all the new and very
> complex
> MLME functions that are being added to 802.11 we do not want this huge
> amount of code in the kernel when it does not need to be there.
