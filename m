From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Sat, 26 May 2012 06:17:47 +0200
Message-ID: <1338005867.10135.10.camel@edumazet-glaptop>
References: <4FC0063E.8080209@fb.com>
	 <20120525.185131.2017517041016424794.davem@davemloft.net>
	 <4FC01F1B.1080009@fb.com>
	 <20120525.201150.1782581593120395710.davem@davemloft.net>
	 <4FC02777.5070003@fb.com>  <1338003580.10135.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338003580.10135.6.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-05-26 at 05:39 +0200, Eric Dumazet wrote:

> But your patch is not a  "modest increase", so whats the deal ?
> 
> A modest increase would be 8192 instead of 4096, regardless of RAM size.
> 
> 

More over, a boot parameter to tweak it is absolutely not needed

sysctl -w net.ipv6.route.max_size=16384

or

echo 16384 >/proc/sys/net/ipv6/route/max_size

IPv4 has to allocate a hash table at boot time, and this hash table is
not resized. Thus some really special purpose machines need a boot
param.
