From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2012-12-07
Date: Fri, 07 Dec 2012 14:10:19 -0500 (EST)
Message-ID: <20121207.141019.1235012151153841155.davem@davemloft.net>
References: <20121207185754.GF1869@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab2LGTKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:10:22 -0500
In-Reply-To: <20121207185754.GF1869@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 7 Dec 2012 13:57:54 -0500

> This includes a Bluetooth pull.  Gustavo says:
> 
> "A few more patches to 3.8, I hope they can still make it to mainline!
> The most important ones are the socket option for the SCO protocol to allow
> accept/refuse new connections from userspace. Other than that I added some
> fixes and Andrei did more AMP work."
> 
> Also, a mac80211 pull.  Johannes says:
> 
> "If you think there's any chance this might make it still, please pull my
> mac80211-next tree (per below). This contains a relatively large number
> of fixes to the previous code, as well as a few small features:
>  * VHT association in mac80211
>  * some new debugfs files
>  * P2P GO powersave configuration
>  * masked MAC address verification
> 
> The biggest patch is probably the BSS struct changes to use RCU for
> their IE buffers to fix potential races. I've not tagged this for stable
> because it's pretty invasive and nobody has ever seen any bugs in this
> area as far as I know."
> 
> Several other drivers get some attention, including ath9k, brcmfmac,
> brcmsmac, and a number of others.  Also, Hauke gives us a series that
> improves watchdog support for the bcma and ssb busses.  Finally, Bill
> Pemberton delivers a group of "remove __dev* attributes" for wireless
> drivers -- these generate some "section mismatch" warnings, but Greg
> K-H assures me that they will disappear by the time -rc1 is released.
> 
> This also includes a pull of the wireless tree to avoid merge
> conflicts.

Pulled, thanks John.
