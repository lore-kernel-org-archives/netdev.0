From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-11-20
Date: Fri, 21 Nov 2014 00:08:18 -0500 (EST)
Message-ID: <20141121.000818.597514678074429997.davem@davemloft.net>
References: <20141120210030.GD31881@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141120210030.GD31881@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 20 Nov 2014 16:00:30 -0500

> Please full this little batch of fixes intended for the 3.18 stream!
> 
> For the mac80211 patch, Johannes says:
> 
> "Here's another last minute fix, for minstrel HT crashing
> depending on the value of some uninitialised stack."
> 
> On top of that...
> 
> Ben Greear fixes an ath9k regression in which a BSSID mask is
> miscalculated.
> 
> Dmitry Torokhov corrects an error handling routing in brcmfmac which
> was checking an unsigned variable for a negative value.
> 
> Johannes Berg avoids a build problem in brcmfmac for arches where
> linux/unaligned/access_ok.h and asm/unaligned.h conflict.
> 
> Mathy Vanhoef addresses another brcmfmac issue so as to eliminate a
> use-after-free of the URB transfer buffer if a timeout occurs.
> 
> Please let me know if there are problems!

Pulled, thanks John.
