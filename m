From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Nov 10 (net/ipv4/ip_tunnel.c)
Date: Mon, 10 Nov 2014 14:24:39 -0500 (EST)
Message-ID: <20141110.142439.2292080248990157625.davem@davemloft.net>
References: <20141110205945.51af32a6@canb.auug.org.au>
	<546100AF.40201@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	therbert@google.com
To: rdunlap@infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <546100AF.40201@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 10 Nov 2014 10:15:11 -0800

> On 11/10/14 01:59, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Changes since 20141106:
>> 
> 
> on x86_64:
> when CONFIG_NET_IP_TUNNEL=y and CONFIG_NET_FOU=m:
> 
> net/built-in.o: In function `ip_tunnel_encap':
> (.text+0xb04d8): undefined reference to `gue_build_header'
> net/built-in.o: In function `ip_tunnel_encap':
> (.text+0xb04ea): undefined reference to `fou_build_header'

Tom, this has now been reported twice, please fix this.

Thanks.
