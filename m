From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] etherdevice: Optimize a few is_<foo>_ether_addr
 functions
Date: Mon, 09 Dec 2013 20:58:38 -0500 (EST)
Message-ID: <20131209.205838.1809285255471420654.davem@davemloft.net>
References: <20131206.163806.1555069105347405484.davem@davemloft.net>
	<1386368461.31845.38.camel@joe-AO722>
	<1386373461.31845.50.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386373461.31845.50.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 06 Dec 2013 15:44:21 -0800

> If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set,
> several is_<foo>_ether_addr functions can be slightly
> improved by using u32 dereferences.
> 
> I believe all current uses of is_zero_ether_addr and
> is_broadcast_ether_addr are u16 aligned, so always use
> u16 references to improve those functions performance.
> 
> Document the u16 alignment requirements.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
