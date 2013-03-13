From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: fixing dst_neigh_lookup/dst_neigh_lookup_skb
 caused kernel panic
Date: Wed, 13 Mar 2013 10:33:42 -0400 (EDT)
Message-ID: <20130313.103342.1152584686012875394.davem@davemloft.net>
References: <CAABZP2yznP5jD6Og=-ZxgAh23VpfM1BGX4OJsOb00KDeyV-jyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, trivial@kernel.org
To: zhouzhouyi@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAABZP2yznP5jD6Og=-ZxgAh23VpfM1BGX4OJsOb00KDeyV-jyA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Wed, 13 Mar 2013 12:00:34 +0800

>  when neighbour table is full, dst_neigh_lookup/dst_neigh_lookup_skb
> will return -ENOBUFS which
> is absolutely non zero, while all the code in kernel which use above
> functions  assume failure only
> on zero return (I did a grep), which will cause kernel panic. (for
> example: https://bugzilla.kernel.org/show_bug.cgi?id=54731)
> 
>   This patch corrects above error with smallest changes to kernel source code.
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>

Your patch was corrupted by your email client.

Fix this, and only resend this patch once you are able to send a test
patch to yourself and cleanly apply the patch you receive.
