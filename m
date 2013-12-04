From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: rx: Neaten ieee80211_deliver_skb, remove
 compare_ether_addr
Date: Wed, 04 Dec 2013 09:16:02 +0100
Message-ID: <1386144962.4284.2.camel@jlt4.sipsolutions.net>
References: <1386095360.15309.29.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386095360.15309.29.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-03 at 10:29 -0800, Joe Perches wrote:
> Remove the unnecessary duplicate test of "if (skb) {"
> when !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
> 
> Remove now unnecessary __maybe_unused, neaten comment
> Remove unnecessary parenthesis around align cast.
> Substitute reference to deprecated compare_ether_addr
> with ether_addr_equal.

I already had a patch to remove the __maybe_unused, but this looks good,
applied.

johannes
