From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-09-05
Date: Sun, 07 Sep 2014 16:11:33 -0700 (PDT)
Message-ID: <20140907.161133.1026363467035732296.davem@davemloft.net>
References: <20140905150453.GB3454@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaIGXLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:11:33 -0400
In-Reply-To: <20140905150453.GB3454@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 5 Sep 2014 11:04:53 -0400

> Please pull this batch of fixes intended for the 3.17 stream...
> 
> For the mac80211 bits, Johannes says:
> 
> "Here are a few fixes for mac80211. One has been discussed for a while
> and adds a terminating NUL-byte to the alpha2 sent to userspace, which
> shouldn't be necessary but since many places treat it as a string we
> couldn't move to just sending two bytes.
> 
> In addition to that, we have two VLAN fixes from Felix, a mesh fix, a
> fix for the recently introduced RX aggregation offload, a revert for
> a broken patch (that luckily didn't really cause any harm) and a small
> fix for alignment in debugfs."
> 
> For the iwlwifi bits, Emmanuel says:
> 
> "I revert a patch that disabled CTS to self in dvm because users
> reported issues. The revert is CCed to stable since the offending
> patch was sent to stable too. I also bump the firmware API versions
> since a new firmware is coming up. On top of that, Marcel fixes a
> bug I introduced while fixing a bug in our Kconfig file."
> 
> Please let me know if there are problems!

Pulled, thanks John.
