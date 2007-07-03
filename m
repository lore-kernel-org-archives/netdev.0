From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Set low initial rate in rc80211_simple
Date: Mon, 02 Jul 2007 22:38:40 -0700 (PDT)
Message-ID: <20070702.223840.99827968.davem@davemloft.net>
References: <20070612012228.GG20422@tuxdriver.com>
	<20070612012319.GH20422@tuxdriver.com>
	<20070612012411.GI20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070612012411.GI20422-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 11 Jun 2007 21:24:11 -0400

> From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> 
> The initial rate for STA's using rc80211_simple is set to the last
> rate in the rate table. For situations for which the signal is weak,
> the rate may be too high for authentication and association. Although
> the rc80211_simple module will adjust the speed, the response may not
> be fast enough for a successful connection. This modification sets the
> initial rate to the lowest supported value.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Applied to net-2.6.23
