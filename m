From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Fri, 14 Dec 2007 12:20:31 +0100
Message-ID: <476266FF.4080300@trash.net>
References: <4762646B.30207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4762646B.30207@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> 1) Using jhash2() instead of jhash() is a litle bit faster if applicable.
> 
> 2) Thanks to jhash, hash value uses full 32 bits.
>    Instead of returning hash % size (implying a divide)
>    we return the high 32 bits of the (hash * size) that will
>    give results between [0 and size-1] and same hash distribution.
> 
>   On most cpus, a multiply is less expensive than a divide, by an order
>   of magnitude.


Clever :) Applied, thanks Eric.

