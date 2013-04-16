From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 3.9] net: fec: fix regression in link change
 accounting
Date: Tue, 16 Apr 2013 16:48:00 -0400 (EDT)
Message-ID: <20130416.164800.1025082844360649756.davem@davemloft.net>
References: <1366108962-8607-1-git-send-email-l.stach@pengutronix.de>
	<CAFeW=pbOsyULqUoA0m6cM+co2HprQT7m=MpSAPHGiUgRrsO6ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.stach@pengutronix.de, netdev@vger.kernel.org
To: kongjianjun@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964981Ab3DPUsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:48:02 -0400
In-Reply-To: <CAFeW=pbOsyULqUoA0m6cM+co2HprQT7m=MpSAPHGiUgRrsO6ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amos Kong <kongjianjun@gmail.com>
Date: Tue, 16 Apr 2013 23:04:24 +0800

> On Tue, Apr 16, 2013 at 6:42 PM, Lucas Stach <l.stach@pengutronix.de> wrote:
> 
>> A link-down isn't properly saved in the FEC state, so we wouldn't restart
>> the
>> FEC after a repeated link-up.
>>
>> Regression was introduced with commit
>> d97e7497 "net: fec: restart the FEC when PHY speed changes"
>>
>> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
>>
> 
> Reviewed-by: Amos Kong <kongjianjun@gmail.com>

Applied.
