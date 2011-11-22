From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2011-11-22
Date: Tue, 22 Nov 2011 15:14:29 -0500 (EST)
Message-ID: <20111122.151429.253381379981773726.davem@davemloft.net>
References: <20111122193505.GC8452@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111122193505.GC8452@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Nov 2011 14:35:05 -0500

> Here is the latest batch of fixes intended for 3.2.  This includes a
> correction for a user-visible error in mac80211's debugfs info, a fix
> for a potential memory corrupter in prism54, an endian fix for rt2x00,
> an endian fix for mac80211, a fix for a NULL derefernce in cfg80211, a
> locking fix and a deadlock fix for p54spi, and a pair of rt2x00 fixes
> for handling some spurious interrupts that hardware can generate.
> 
> Please let me know if there are problems!

The rt2800pci change doesn't look correct.

If the IRQ line is shared with another device, this change will make it
never see interrupts.  Once you say "IRQ_HANDLED" the IRQ dispatch
stops processing the interrupt handler list.
