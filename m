From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Mon, 04 Jul 2005 14:26:04 -0700 (PDT)
Message-ID: <20050704.142604.18592223.davem@davemloft.net>
References: <42B982D4.9040704@cosmosbay.com>
	<1119467012.5325.15.camel@rh4>
	<42C9A884.1030906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42C9A884.1030906@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 04 Jul 2005 23:22:12 +0200

> But it seems something is wrong because when network load becomes high I get :
> 
> Jul  4 23:01:19 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Jul  4 23:01:19 dada1 kernel: tg3: eth0: transmit timed out, resetting
> Jul  4 23:01:24 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Jul  4 23:01:24 dada1 kernel: tg3: eth0: transmit timed out, resetting
> Jul  4 23:01:29 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out

Does this happen without changing the coalescing settings
at all?
