From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is LRO off by default on ixgbe?
Date: Fri, 25 Sep 2009 14:53:48 -0700
Message-ID: <4ABD3BEC.8040006@candelatech.com>
References: <4ABA57D1.5000905@candelatech.com> <20090925213727.GA3291@gondor.apana.org.au> <20090925214303.GA3399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58414 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbZIYVzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:55:46 -0400
In-Reply-To: <20090925214303.GA3399@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2009 02:43 PM, Herbert Xu wrote:
> On Fri, Sep 25, 2009 at 02:37:27PM -0700, Herbert Xu wrote:
>>
>>> Ok.  It seems GRO was enabled the whole time, but LRO is what gave me the
>>> extra performance boost.
>>>
>>> In this particular case, I'm not actually routing, though I do have ip-forward
>>> enabled, so I guess LRO will be OK as long as I'm careful...
>>
>> What? A driver is either GRO or LRO, it can't be both.  What
>> kernel version was this?
>
> Oh perhaps you mean LRO performed by hardware? That would make
> sense indeed.  It's also one of the reasons why we hope the hardware
> folks would switch over to GRO so we can enable it for everyone :)

I assume it's in hardware.  I am using ixgbe driver, 82599 chipset,
2.6.31 kernel.

GRO was showing as enabled the whole time in ethtool.  Turning on LRO gave me an extra
6Gbps (from 12Gbps -> 18Gbps) receive throughput, so it certainly had some affect!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

