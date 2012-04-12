From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-04-12
Date: Thu, 12 Apr 2012 12:51:06 -0400 (EDT)
Message-ID: <20120412.125106.1852994075956058784.davem@davemloft.net>
References: <20120412142859.GB21495@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120412142859.GB21495@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 12 Apr 2012 10:28:59 -0400

> This is a flurry of fixes intended for 3.4...
> 
> Many of these are Bluetooth fixes.  Gustavo says:
> 
> "This is a batch of fixes for 3.4. We have added support to 3 new
> devices, fixes some NULL-pointer dereferences, memory leaks, memory
> corruption and endian bugs. There was also a userspace compatibility
> fix reported by Keith Packard on lkml. The fixes are all simple."
> 
> On top of the Bluetooths bits, we have a number of wireless fixes.
> One is an rt2x00 fix from Chien-Chia Chen which fixes the rfkill
> registration so that it still works even if the box is booted with the
> device already blocked.  Johannes Berg gives us a pair of fixes, one
> that corrects a macro parameter when setting a beacon wait timeout, and
> another that ensures that the proper interface state is used throughout
> nl80211 so as to avoid warnings and unintended driver behavior.
> Julia Lawall gives us a fix for a memory leak in an error handling
> case.  Larry Finger is the star performer for this round, giving us a
> fix for firmware initialization in rtl8192de, a mac80211 fix to quiet
> some log spam, a fix to avoid a NULL pointer dereference in rtlwifi, an
> rtlwifi fix to avoid a "sleeping function called from invalid context"
> BUG, and another rtlwifi fix to avoid "Out of SW-IOMMU space" errors.
> Paul Gortmaker gives us a fix to avoid bcma build breakage on MIPS.
> Samuel Ortiz fixes a loop in NFC's LLCP Tx frame fragmentation loop.
> And finally, Sujith Manoharan reverts an earlier patch in order to
> fix a regression reported by a number of ath9k users.

Pulled, thanks John.
