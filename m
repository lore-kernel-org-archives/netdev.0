From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Wed, 02 May 2012 21:35:32 -0400 (EDT)
Message-ID: <20120502.213532.2065398707446945634.davem@davemloft.net>
References: <20120503113110.3eded43c5dc526a471c69dd2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ashok@cozybit.com,
	netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120503113110.3eded43c5dc526a471c69dd2@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 3 May 2012 11:31:10 +1000

> Today's linux-next merge of the wireless-next tree got a conflict in
> net/wireless/nl80211.c between commit 9360ffd18597 ("wireless: Stop using
> NLA_PUT*()") from the net-next tree and commit 0a9b3782ef40 ("{nl,cfg,mac}
> 80211: Allow user to see/configure HT protection mode") from the
> wireless-next tree.

John, the NLA_PUT macros were removed from the net-next tree more
than a month ago.

There is zero reason why this should still be happening, and this
issue is causing a large, unnecessary, burdon upon Stephen.

Please take care of this, thanks.
