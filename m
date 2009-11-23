From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Sun, 22 Nov 2009 17:19:32 -0800 (PST)
Message-ID: <20091122.171932.74107512.davem@davemloft.net>
References: <20091123120052.dd388203.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091123120052.dd388203.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 23 Nov 2009 12:00:52 +1100

> Today's linux-next merge of the net tree got a conflict in
> drivers/ieee802154/fakehard.c between commit
> 56cf54831fd1be105e89a9df899e3b22442da180 ("ieee802154: dont leak skbs in
> ieee802154_fake_xmit()") from the net-current tree and commit
> 8964be4a9a5ca8cab1219bb046db2f6d1936227c ("net: rename skb->iif to
> skb->skb_iif") from the net tree.
> 
> The former removed the code modified by the latter, so I used the former.

Hmmm... I specifically remember taking core of this conflict when I
merged net-next-2.6 into net-2.6 yesterday or the day before.
