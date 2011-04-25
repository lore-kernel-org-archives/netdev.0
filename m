From: David Miller <davem@davemloft.net>
Subject: Re: Oops in 2.6.39 include/net/dst.h: dst_metrics_write_ptr()
 running l2tp over ipsec
Date: Mon, 25 Apr 2011 11:54:29 -0700 (PDT)
Message-ID: <20110425.115429.193701951.davem@davemloft.net>
References: <4DB4A619.9080600@gmx.de>
	<1303718852.2747.103.camel@edumazet-laptop>
	<4DB54450.90806@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: berny156@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DB54450.90806@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Held Bernhard <berny156@gmx.de>
Date: Mon, 25 Apr 2011 11:52:16 +0200

> Am 25.04.2011 10:07, schrieb Eric Dumazet:
>> From: Held Bernhard<berny156@gmx.de>
 ...
>> Thanks for your report and patch.
>>
>> Maybe following patch is the way to fix this, please test it.
>>
>>
>> [PATCH] net: provide cow_metrics() methods to blackhole dst_ops
 ...
>> The oops happens in dst_metrics_write_ptr()
>> include/net/dst.h:124: return dst->ops->cow_metrics(dst, p);
>>
>> dst->ops->cow_metrics is NULL and causes the oops.
>>
>> Provide cow_metrics() methods, like we did in commit 214f45c91bb
>> (net: provide default_advmss() methods to blackhole dst_ops)
>>
>> Signed-off-by: Held Bernhard<berny156@gmx.de>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
 ...
> Your patch works flawlessly.
> 
> Thanks for the quick response!

Applied, thanks everyone.
