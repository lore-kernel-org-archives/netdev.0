From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] net: l2tp: only set L2TP_ATTR_UDP_CSUM
 if AF_INET
Date: Wed, 09 Nov 2016 18:56:30 -0500 (EST)
Message-ID: <20161109.185630.2218369657420333518.davem@davemloft.net>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
        <20161107203928.30111-2-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-2-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Mon,  7 Nov 2016 20:39:25 +0000

> Only set L2TP_ATTR_UDP_CSUM in l2tp_nl_tunnel_send()
> when it's running over IPv4.
> 
> This prepares the code to also have IPv6 specific attributes.
> 
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
