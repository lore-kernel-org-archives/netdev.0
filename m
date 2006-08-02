From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to
 be inserted header in outbound.
Date: Wed, 02 Aug 2006 17:31:24 +0900
Message-ID: <44D062DC.7060700@linux-ipv6.org>
References: <11541654231584-git-send-email-nakam@linux-ipv6.org>	<20060801.170916.21925105.davem@davemloft.net>	<44D00BEE.8090504@linux-ipv6.org> <20060801.211104.34486178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:21650 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751364AbWHBIb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 04:31:27 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.211104.34486178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Wed, 02 Aug 2006 11:20:30 +0900
> 
>> David Miller wrote:
>>> I see a dangerous pattern of adding many, many, many methods
>>> to the xfrm_type structure which are only used by ipv6.
>>> But I cannot suggest another method.
>> Sometimes this is a difficult point for me to design.
> 
> Do not worry so much about it right now, it is not a barrier
> for code integration.  We can try to refine this later on.

OK, I improve my code for current framework at first.
Thanks :-)

-- 
Masahide NAKAMURA
