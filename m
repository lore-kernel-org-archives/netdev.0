From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-01-23
Date: Sun, 27 Jan 2013 01:39:28 -0500 (EST)
Message-ID: <20130127.013928.1867901911175664439.davem@davemloft.net>
References: <20130123201605.GC5221@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123201605.GC5221@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 23 Jan 2013 15:16:06 -0500

> This is a batch of fixes intende for the 3.8 stream.
> 
> Regarding the iwlwifi bits, Johannes says this:
> 
> "Please pull to get a single fix from Emmanuel for a bug I introduced due
> to misunderstanding the code."
> 
> Regarding the mac80211 bits, Johannes says this:
> 
> "I have a few small fixes for you:
>  * some mesh frames would cause encryption warnings -- fixes from Bob
>  * scanning would pretty much break an association if we transmitted
>    anything to the AP while scanning -- fix from Stanislaw
>  * mode injection was broken by channel contexts -- fix from Felix
>  * FT roaming was broken: hardware crypto would get disabled by it"
> 
> Along with that, a handful of other fixes confined to specific drivers.
> 
> Avinash Patil fixes a typo in a NULL check in mwifiex.
> 
> Larry Finger fixes a build warning in rtlwifi.  Seems safe...
> 
> Stanislaw Gruszka fixes iwlegacy to prevent microcode errors when
> switching from IBSS mode to STA mode.
> 
> Felix Fietkau provides a trio of ath9k fixes related to proper tuning.
> 
> Please let me know if there are problems!

Pulled, thanks John.
