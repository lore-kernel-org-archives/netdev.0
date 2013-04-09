From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Use bool not int
Date: Tue, 09 Apr 2013 17:08:15 -0400 (EDT)
Message-ID: <20130409.170815.1687417824367136494.davem@davemloft.net>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
	<1365538694.18072.8.camel@joe-AO722>
	<1365541211.2200.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, nsujir@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936415Ab3DIVIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 17:08:17 -0400
In-Reply-To: <1365541211.2200.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 9 Apr 2013 14:00:11 -0700

> On Tue, 2013-04-09 at 13:18 -0700, Joe Perches wrote:
>> Using bool can make code more readable.
>> 
>> Convert uses and tests of int to bool.
>> 
>> This also makes a comparison of tg3->link_up
>> (itself bool) a bool comparison instead of int.
>> 
>> Reorder stack variable declarations to make
>> bool fit declaration holes where appropriate.
>> 
>> $ size drivers/net/ethernet/broadcom/tg3.o*
>>    text    data     bss     dec     hex filename
>>  169958   27249   58896  256103   3e867 drivers/net/ethernet/broadcom/tg3.o.new
>>  169968   27249   58896  256113   3e871 drivers/net/ethernet/broadcom/tg3.o.old
>> 
>> Signed-off-by: Joe Perches <joe@perches.com> 
> 
> Thanks.
> 
> Reviewed-by: Michael Chan <mchan@broadcom.com>

Applied.
