From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tile: fix missing unlock on error in
 tile_net_open()
Date: Mon, 05 Aug 2013 11:09:52 -0700 (PDT)
Message-ID: <20130805.110952.1951566477787815733.davem@davemloft.net>
References: <CAPgLHd8k5yfO4G1Fvz86VSC-HbwgGEb8OwTShAa5e+owRvaMqg@mail.gmail.com>
	<51FFC065.3090108@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab3HESJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:09:53 -0400
In-Reply-To: <51FFC065.3090108@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 5 Aug 2013 11:10:29 -0400

> On 8/5/2013 12:42 AM, Wei Yongjun wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> Add the missing unlock before return from function tile_net_open()
>> in the error handling case.
>>
>> Introduced by commit f3286a3af89d6db7a488f3e8f02b98d67d50f00c.
>> (tile: support multiple mPIPE shims in tilegx network driver)
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> ---
>>  drivers/net/ethernet/tile/tilegx.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Thanks!
> 
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>

Applied.
