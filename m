From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH,RFT] ieee80211: Move IV/ICV stripping into ieee80211_rx
Date: Mon, 25 Sep 2006 10:58:03 +0200
Message-ID: <1159174683.4509.11.camel@ux156>
References: <20060924224317.D294E7B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de, yi.zhu@intel.com,
	jketreno@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12710 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750801AbWIYI5O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 04:57:14 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060924224317.D294E7B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 23:43 +0100, Daniel Drake wrote:
> This patch adds a host_strip_iv_icv flag to ieee80211 which indicates that
> ieee80211_rx should strip the IV/ICV/other security features from the payload.
> This saves on some memmove() calls in the driver and seems like something that
> belongs in the stack as it can be used by bcm43xx, ipw2200, and zd1211rw
> 
> I need someone to test this on ipw2200 as I don't have the hardware.
> As hardware decryption is disabled in bcm43xx I'm guessing that the code doesn't
> work yet? Either way I have added in the necessary changes should it be
> enabled in the future.
> 
> This patch also adds some sensible variable reuse (idx vs keyidx) in
> ieee80211_rx
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Looks good to me. As for bcm43xx, yes, the hw crypto isn't working
perfectly yet. There's actually an option to enable it though, so the
patch might need some changes.

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
