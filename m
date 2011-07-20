From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: fix ethtool_get_regs() to work with zero
 length registers
Date: Wed, 20 Jul 2011 13:38:09 +0200
Message-ID: <1311161889.1041.11.camel@localhost>
References: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35998 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab1GTLiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 07:38:17 -0400
In-Reply-To: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-20 at 12:18 +0300, Kalle Valo wrote:
> cfg80211 exports zero length register size as it currently only uses
> struct ethtool_regs.version to export struct wiphy.hw_version.
[...]

The ethtool_regs::version field represents the version of the register
dump format.  This may or may not relate to a hardware version.

If you don't actually provide a register dump then don't implement this
operation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

