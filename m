From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net/cadence: get rid of HAVE_NET_MACB
Date: Mon, 22 Oct 2012 03:10:45 -0400 (EDT)
Message-ID: <20121022.031045.256369748618729011.davem@davemloft.net>
References: <1350829392-3812-2-git-send-email-manabian@gmail.com>
	<20121021.192707.1747557282711878897.davem@davemloft.net>
	<CAGhQ9VyPNDKWwGCZ2Mghm7dOcyTqTgL=ahv+1EQaXtz-Hd7OMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, hskinnemoen@gmail.com,
	egtvedt@samfundet.no, plagnioj@jcrosoft.com, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737Ab2JVHKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 03:10:49 -0400
In-Reply-To: <CAGhQ9VyPNDKWwGCZ2Mghm7dOcyTqTgL=ahv+1EQaXtz-Hd7OMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim  Eastwood <manabian@gmail.com>
Date: Mon, 22 Oct 2012 08:59:17 +0200

> On Mon, Oct 22, 2012 at 1:27 AM, David Miller <davem@davemloft.net> wrote:
>>
>> You do know that this is going to generate warnings on 64-bit
>> platforms?
>>
>> I was hoping you would have noticed and corrected this before
>> enabling the driver everywhere, I guess my expectations were
>> way too high :-/
> 
> ah, sorry.
> 
> Yes, macb seem to generate some integer overflows on ~0UL on 64-bit. I
> have a patch that turns ~0UL into -1.
> 
> I can repost the series with fix included. Do you want me to do that?

Yes, please do.

Thanks.
