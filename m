From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-08-19
Date: Tue, 20 Aug 2013 17:26:19 -0700 (PDT)
Message-ID: <20130820.172619.2224001430937589898.davem@davemloft.net>
References: <20130819185940.GE30753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130819185940.GE30753@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 19 Aug 2013 14:59:40 -0400

> This is a batch of fixes intended for the 3.11 stream...
> 
> Regarding the iwlwifi bits, Johannes says:
> 
> "We revert an rfkill bugfix that unfortunately caused more bugs, shuffle
> some code to avoid touching the PCIe device before it's enabled and
> disconnect if firmware fails to do our bidding. I also have Stanislaw's
> fix to not crash in some channel switch scenarios."
> 
> As for the mac80211 bits, Johannes says:
> 
> "This time, I have one fix from Dan Carpenter for users of
> nl80211hdr_put(), and one fix from myself fixing a regression with the
> libertas driver."
> 
> Along with the above...
> 
> Dan Carpenter fixes some incorrectly placed "address of" operators
> in hostap that caused copying of junk data.
> 
> Jussi Kivilinna corrects zd1201 to use an allocated buffer rather
> than the stack for a URB operation.
> 
> Please let me know if there are problems!

Pulled, thanks John.
