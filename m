From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/smsc911x: Always wait for the chip to be ready
Date: Mon, 14 Nov 2011 00:41:02 -0500 (EST)
Message-ID: <20111114.004102.1105906943928703826.davem@davemloft.net>
References: <1319616343-6357-1-git-send-email-linus.walleij@stericsson.com>
	<CAKnu2MoraoPsqBa9KSHHCG=8avrk_thdNEox1RUTRUGZKr14kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	mathieu.poirier@linaro.org, robert.marklund@stericsson.com
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab1KNFlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:41:11 -0500
In-Reply-To: <CAKnu2MoraoPsqBa9KSHHCG=8avrk_thdNEox1RUTRUGZKr14kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Tue, 8 Nov 2011 11:34:01 +0100

> 2011/10/26 Linus Walleij <linus.walleij@stericsson.com>:
> 
>> From: Robert Marklund <robert.marklund@stericsson.com>
>>
>> Wait for the chip to be ready before any access to it. On the
>> Snowball platform we need to enable an external regulator before
>> the chip comes online, and then it happens that the device is
>> not yet ready at probe time, so let's wait for it.
>>
>> Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
>> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> 
> Since there doesn't seem to be any consternation concerning
> this first patch, can it be applied?

Applied, thanks.
