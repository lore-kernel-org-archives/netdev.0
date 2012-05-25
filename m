From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 15:22:54 -0700
Message-ID: <4FC0063E.8080209@fb.com>
References: <1337976934-18065-1-git-send-email-asharma@fb.com> <1337978820.10135.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337978820.10135.1.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/25/12 1:47 PM, Eric Dumazet wrote:
> On Fri, 2012-05-25 at 13:15 -0700, Arun Sharma wrote:
>> The algorithm is based on ipv4 and alloc_large_system_hash().
>>
>
> Why is it needed at all ?
>
> IPv4 has a route cache with potentially millions of entries, not IPv6.

With the default size of 4096 for the ipv6 routing table, entries can 
get garbage collected and hosts could lose their default route and 
therefore lose connectivity.

We actually saw it happen.

  -Arun
