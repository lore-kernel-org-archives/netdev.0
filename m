From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 22:38:29 -0500 (EST)
Message-ID: <20111222.223829.536447332324142274.davem@davemloft.net>
References: <1324528656.2621.19.camel@edumazet-laptop>
	<4EF300B2.3050903@bootc.net>
	<1324563353.2153.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bootc@bootc.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324563353.2153.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Dec 2011 15:15:53 +0100

> [PATCH] net: introduce DST_NOPEER dst flag
> 
> Chris Boot reported crashes occurring in ipv6_select_ident().
 ...
> This is caused by bridge netfilter special dst_entry (fake_rtable), a
> special shared entry, where attaching an inetpeer makes no sense.
> 
> Problem is present since commit 87c48fa3b46 (ipv6: make fragment
> identifications less predictable)
> 
> Introduce DST_NOPEER dst flag and make sure ipv6_select_ident() and
> __ip_select_ident() fallback to the 'no peer attached' handling.
> 
> Reported-by: Chris Boot <bootc@bootc.net>
> Tested-by: Chris Boot <bootc@bootc.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
