From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in
 TX path
Date: Fri, 28 Sep 2012 03:10:27 -0400 (EDT)
Message-ID: <20120928.031027.963540575540777486.davem@davemloft.net>
References: <CF9D1877D81D214CB0CA0669EFAE020C6562EE@CMEXMB1.ad.emulex.com>
	<20120928.024034.1426515423229309957.davem@davemloft.net>
	<CF9D1877D81D214CB0CA0669EFAE020C65638C@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab2I1HK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 03:10:29 -0400
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C65638C@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Date: Fri, 28 Sep 2012 07:05:27 +0000

>>-----Original Message-----
>>From: David Miller [mailto:davem@davemloft.net]
>>
>>> endianness is handled even in this patch. The call to wrb_fill_hdr()
>>> is followed by be_dws_cpu_to_le() to handle this.
>>
>>That swap_dws() thing is the most inefficient thing I've ever seen.
>>
>>Instead of being able to benefit from compile time optimizations
>>such as byte swaps of constants, you do everything hidden from the
>>compiler so nothing gets optimized.
> 
> I'd like to clarify that swap_dws() was being used/needed even in
> the old code.

I fully understand this.
