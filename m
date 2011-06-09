From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-06-09
Date: Thu, 09 Jun 2011 13:20:20 -0700 (PDT)
Message-ID: <20110609.132020.549281704173055530.davem@davemloft.net>
References: <20110609191632.GA16198@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110609191632.GA16198@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 9 Jun 2011 15:16:32 -0400

> There are two reverts, both in mac80211.  One was found to cause a
> regression.  The other revert was requested by the mac80211 maintainer
> (Johannes) on the basis of API abuse and a lack of faith that the
> implementation actual did anything useful. :-(
> 
> This includes a fix for an IBSS-related race condition from Johannes,
> and a fix for an nl80211 integer overflow from Luca.  Also included
> are a couple of rtlwifi fixes from Mike McCormack, one that fixes a
> packet dropping error, and another that avoids incorrectly modifying
> a resubmitted skb.  But the big hero this round is Stanislaw, who
> not only identified a fix from Wey-Yi that need to go for 3.0 rather
> than 3.1, but he also fixed an rmmod crash in rt2x00, a locking issue
> in iwlgacy, a power setting bug in iwl4965, and an 802.11n general
> instability issue on iwlagn.  As a result, I am researching popular
> beers in the Czech Republic... :-)
> 
> Please let me know if there are problems!

Pulled, thanks!
