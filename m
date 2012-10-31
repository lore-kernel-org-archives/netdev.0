From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-10-31
Date: Wed, 31 Oct 2012 14:59:53 -0400 (EDT)
Message-ID: <20121031.145953.337833949642239663.davem@davemloft.net>
References: <20121031173740.GB30910@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121031173740.GB30910@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 31 Oct 2012 13:37:40 -0400

> The biggest portion of this is a pull request from Johannes Berg:
> 
> "Please pull my mac80211.git tree per below to get a number of fixes. I
> have included a patch from Antonio to fix a memcpy overrun, Felix's
> patches for the antenna gain/tx power issues, a few mesh-related fixes
> from Javier for mac80211 and my own patches to not access data that
> might not be present in an skb at all as well as a patch (the duplicate
> IE check one) to make mac80211 forward-compatible with potential future
> spec extensions that use the same IE multiple times.
> 
> It's a bit bigger than I'd like maybe, but I think all of these are
> worthwhile fixes at this point."
> 
> In addition...
> 
> Felix Fietkau fixes an ath9k use-after-free issue.
> 
> Stanislaw Gruszka adds a valid value check to rt2800.
> 
> Sven Eckelmann adds a check to only check a TID value in a BlockAck, for
> frames that could be either a BlockAck or a normal Ack.

Pulled, thanks John.
