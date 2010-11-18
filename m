From: Patrick McHardy <kaber@trash.net>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 19:12:00 +0100
Message-ID: <4CE56C70.8090404@trash.net>
References: <1290093135.2781.167.camel@edumazet-laptop>	<4CE561A2.2020600@gmail.com>	<1290102497.2781.242.camel@edumazet-laptop> <20101118.095046.28818361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, justinmattock@gmail.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, horms@verge.net.au,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101118.095046.28818361.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.11.2010 18:50, schrieb David Miller:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 18 Nov 2010 18:48:17 +0100
> 
>> Let me guess...
>>
>> net/netfilter/nf_conntrack_core is compiled as a module, and ip_vs
>> statically (in vmlinux) ?
>>
>> CONFIG_NF_CONNTRACK=m
>> CONFIG_IP_VS=y
>>
>> We probably need some Kconfig magic ;)
> 
> Randy Dunlap made a similar report today with a sample .config
> that triggers the problem.
> 
> I'll look into it after lunch.

Thanks, I'll take care of this.
