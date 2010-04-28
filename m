From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 09:53:46 -0700 (PDT)
Message-ID: <20100428.095346.140747800.davem@davemloft.net>
References: <1272406693.2343.26.camel@edumazet-laptop>
	<20100427.151937.62344362.davem@davemloft.net>
	<1272460455.30392.24.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eliezert@gmail.com, eric.dumazet@gmail.com,
	xiaosuo@gmail.com, hadi@cyberus.ca, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704Ab0D1Qxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 12:53:40 -0400
In-Reply-To: <1272460455.30392.24.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 28 Apr 2010 16:14:15 +0300

> On Tue, 2010-04-27 at 15:19 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 28 Apr 2010 00:18:13 +0200
>> 
>> > [PATCH net-next-2.6] bnx2x: Remove two prefetch()
>> > 
>> > 1) Even on 64bit arches, sizeof(struct sk_buff) < 256
>> > 2) No need to prefetch same pointer twice.
>> > 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > CC: Eilon Greenstein <eilong@broadcom.com>
>> 
>> Eilon please review and ACK/NACK
> 
> Vlad ran few benchmarks, and we couldn't find any justification for
> those prefetch calls. After consulting with Eliezer Tamir (the original
> author) we are glad to Ack this patch.
> 
> Thanks Eric!
> Acked-by: <eilong@broadcom.com>

Thanks, applied.

Please put your full name as well as your email address in Acked-by:
tags, just like you do for Signed-off-by: tags.
