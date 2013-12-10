From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] etherdevice: Add ether_addr_equal_unaligned
Date: Mon, 09 Dec 2013 20:58:22 -0500 (EST)
Message-ID: <20131209.205822.126859687683341998.davem@davemloft.net>
References: <1386364621.31845.32.camel@joe-AO722>
	<20131206.163806.1555069105347405484.davem@davemloft.net>
	<1386368461.31845.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386368461.31845.38.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 06 Dec 2013 14:21:01 -0800

> Add a generic routine to test if possibly unaligned
> to u16 Ethernet addresses are equal.
> 
> If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set,
> this uses the slightly faster generic routine
> ether_addr_equal, otherwise this uses memcmp.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
