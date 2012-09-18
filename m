From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix memory leak on oom with zerocopy
Date: Tue, 18 Sep 2012 16:25:14 -0400 (EDT)
Message-ID: <20120918.162514.1950372124026735732.davem@davemloft.net>
References: <20120916084416.GA22936@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, bhutchings@solarflare.com,
	mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120916084416.GA22936@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 16 Sep 2012 11:44:16 +0300

> If orphan flags fails, we don't free the skb
> on receive, which leaks the skb memory.
> 
> Return value was also wrong: netif_receive_skb
> is supposed to return NET_RX_DROP, not ENOMEM.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks Michael.
