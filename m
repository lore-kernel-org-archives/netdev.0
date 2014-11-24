From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: fix sparse warning
Date: Mon, 24 Nov 2014 16:16:03 -0500 (EST)
Message-ID: <20141124.161603.798932139185654908.davem@davemloft.net>
References: <1416828696-3989-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dborkman@redhat.com,
	edumazet@google.com, atzm@stratosphere.co.jp,
	hannes@stressinduktion.org, therbert@google.com,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416828696-3989-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 24 Nov 2014 13:32:16 +0200

> af_packet produces lots of these:
> 	net/packet/af_packet.c:384:39: warning: incorrect type in return expression (different modifiers)
> 	net/packet/af_packet.c:384:39:    expected struct page [pure] *
> 	net/packet/af_packet.c:384:39:    got struct page *
> 
> this seems to be because sparse does not realize that _pure
> refers to function, not the returned pointer.
> 
> Tweak code slightly to avoid the warning.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, please report the sparse bug if you haven't already.

Thanks.
