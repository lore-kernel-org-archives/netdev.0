From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2013-04-10
Date: Wed, 10 Apr 2013 15:51:31 -0400 (EDT)
Message-ID: <20130410.155131.1606837345365804721.davem@davemloft.net>
References: <20130410171825.GB15428@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763884Ab3DJTvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 15:51:37 -0400
In-Reply-To: <20130410171825.GB15428@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 10 Apr 2013 13:18:25 -0400

> Please accept this pull request for the 3.10 stream...
> 
> Regarding the mac80211 bits, Johannes says:
> 
> "Here I have a bunch of minstrel fixes from Felix, per-interface
> multicast filtering from Alex, set_tim debouncing from Ilan,
> per-interface debugfs cleanups from Stanislaw, an error return fix from
> Wei and a number of small improvements and fixes that I made myself."
> 
> And for the iwlwifi bits, Johannes says:
> 
> "Andrei changed an instance of kmalloc+memdup to kmemdup, Stanislaw
> removed the now unused 5ghz_disable module parameter. I also have a
> number of fixes from Ilan, Emmanuel and myself, Emmanuel also continued
> working on Bluetooth coexistence."
> 
> For the sizeable batch of Bluetooth bits, Gustavo says:
> 
> "This is our first batch of patches for 3.10. The biggest changes of this pull
> request are from Johan Hedberg, he implemented a HCI request framework to make
> life easier when we have to send many HCI commands and a block and wait for
> all of the to finish, we were able to fix a few issues in stack with the
> introduction of this framework.
> 
> Other than that Dean Jenkins did a good work cleaning the RFCOMM code, the
> refcnt infrastructure was removed and now we use NULL pointer checks to know
> when a object was freed or not. That code was buggy and now it looks a way
> better.
> 
> The rest of changes are clean ups, fixes and small improvements all over the
> Bluetooth subsystem."
> 
> Regarding the wl12xx bits, Luca says:
> 
> "Some patches intended for 3.10.  Mostly bug fixes and other small
> improvements."
> 
> On top of that, there are updates to brcmfmac, brcmsmac, b43, ssb and
> bcma, as well as mwifiex, rt2x00, and ath9k and a few others.  The most
> notable bit is the addition of a new driver in the rtlwifi family.
> 
> Please let me know if there are problems!
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem

Pulled, thanks John.
