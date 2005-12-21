From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 4/5] I/OAT DMA support and TCP acceleration
Date: Tue, 20 Dec 2005 23:37:39 -0800 (PST)
Message-ID: <20051220.233739.30595170.davem@davemloft.net>
References: <43A8F43B.6020307@cosmosbay.com>
	<41b516cb0512202305p45439464o6b7ba6c2c88062bc@mail.gmail.com>
	<41b516cb0512202310q78d5a25apab3c9d6fbb17089e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932314AbVLUHhk@vger.kernel.org>
To: chris.leech@gmail.com
In-Reply-To: <41b516cb0512202310q78d5a25apab3c9d6fbb17089e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <chris.leech@gmail.com>
Date: Tue, 20 Dec 2005 23:10:07 -0800

>  That could be a good way to deal with it.  Actually, I should double
> check the length of tcp_skb_cb.  I took a quick look and thought that
> there might be some room left there anyway, even though the comment in
> tcp.h says otherwise.

There isn't, it's basically full on 64-bit systems with ipv6 enabled.

Just put the DMA cookie object explicitly into struct sk_buff,
protected by CONFIG_NET_DMA.
