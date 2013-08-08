From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-08-08
Date: Thu, 08 Aug 2013 14:12:41 -0700 (PDT)
Message-ID: <20130808.141241.2150105195238423513.davem@davemloft.net>
References: <20130808172940.GC30925@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130808172940.GC30925@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 8 Aug 2013 13:29:40 -0400

> This is a batch of fixes intended for the 3.11 queue...
> 
> Regarding the mac80211 (and related) bits, Johannes says:
> 
> "I have a fix from Chris for an infinite loop along with fixes from
> myself to prevent it entering the loop to start with (continue using
> disabled channels, many thanks to Chris for his debug/test help) and a
> workaround for broken APs that advertise a bad HT primary channel in
> their beacons. Additionally, a fix for another attrbuf race in mac80211
> and a fix to clean up properly while P2P GO interfaces go down."
> 
> Along with that...
> 
> Solomon Peachy corrects a range check in cw1200 that would lead to
> a BUG_ON when starting AP mode.
> 
> Stanislaw Gruszka provides an iwl4965 patch to power-up the device
> earlier (avoiding microcode errors), and another iwl4965 fix that
> resets the firmware after turning rfkill off (resolving a bug in the
> Red Hat Bugzilla).
> 
> Please let me know if there are problems!

Pulled, thanks John.
