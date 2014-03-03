From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-03-03
Date: Mon, 03 Mar 2014 16:43:06 -0500 (EST)
Message-ID: <20140303.164306.910146738456793917.davem@davemloft.net>
References: <20140303194432.GD26300@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbaCCVnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:43:08 -0500
In-Reply-To: <20140303194432.GD26300@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 3 Mar 2014 14:44:32 -0500

> Please pull this batch of fixes intended for the 3.14 stream...
> 
> For the mac80211 bits, Johannes says:
> 
> "This time I have a fix to get out of an 'infinite error state' in case
> regulatory domain updates failed and two fixes for VHT associations: one
> to not disconnect immediately when the AP uses more bandwidth than the
> new regdomain would allow after a change due to association country
> information getting used, and one for an issue in the code where
> mac80211 doesn't correctly ignore a reserved field and then uses an HT
> instead of VHT association."
> 
> For the iwlwifi bits, Emmanuel says:
> 
> "Johannes fixes a long standing bug in the AMPDU status reporting.
> Max fixes the listen time which was way too long and causes trouble
> to several APs."
> 
> Along with those, Bing Zhao marks the mwifiex_usb driver as _not_
> supporting USB autosuspend after a number of problems with that have
> been reported.
> 
> Please let me know if there are problems!

Pulled, thanks John.
