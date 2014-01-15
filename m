From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] etherdevice: Use ether_addr_copy to copy
 an Ethernet address
Date: Wed, 15 Jan 2014 15:39:51 -0800 (PST)
Message-ID: <20140115.153951.743060257410154565.davem@davemloft.net>
References: <1389741527.24849.68.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-arch@vger.kernel.org
To: joe@perches.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1389741527.24849.68.camel@joe-AO722>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 14 Jan 2014 15:18:47 -0800

> Some systems can use the normally known u16 alignment of
> Ethernet addresses to save some code/text bytes and cycles.
> 
> This does not change currently emitted code on x86 by gcc 4.8.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This looks fine, in fact I'll apply it.
