From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mac802154: use kfree_skb() instead of
 dev_kfree_skb()
Date: Fri, 30 Nov 2012 12:19:50 -0500 (EST)
Message-ID: <20121130.121950.939471280361329069.davem@davemloft.net>
References: <504EA95C.9010003@signal11.us>
	<1354249511-8086-1-git-send-email-alan@signal11.us>
	<1354249511-8086-2-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	eric.dumazet@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354249511-8086-2-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Thu, 29 Nov 2012 23:25:11 -0500

> kfree_skb() indicates failure, which is where this is being used.
> 
> Signed-off-by: Alan Ott <alan@signal11.us>

Applied.
