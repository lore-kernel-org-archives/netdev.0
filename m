From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Sat, 26 May 2012 20:54:34 -0700
Message-ID: <4FC1A57A.7080807@fb.com>
References: <4FC0063E.8080209@fb.com>  <20120525.185131.2017517041016424794.davem@davemloft.net>  <4FC01F1B.1080009@fb.com>  <20120525.201150.1782581593120395710.davem@davemloft.net>  <4FC02777.5070003@fb.com> <1338003580.10135.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338003580.10135.6.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/25/12 8:39 PM, Eric Dumazet wrote:
>
> But your patch is not a  "modest increase", so whats the deal ?
>
> A modest increase would be 8192 instead of 4096, regardless of RAM size.
>

Yes - 8192 solves our immediate problem, but I was worrying that the 
problem might resurface as ipv6 adoption becomes more widespread.

We were testing a pre-3.0 kernel that didn't have Dave's DST_NOCOUNT 
patch. Will retest with that patch applied.

 > More over, a boot parameter to tweak it is absolutely not needed

Agreed. Will remove that part.

Still not sure why you'd like to go for one size regardless of 
totalram_pages.

  -Arun
