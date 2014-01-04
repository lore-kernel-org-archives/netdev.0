From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sat, 4 Jan 2014 13:20:28 +0800
Message-ID: <CAPshTCgnwX4g1CSgrEK+OwRPjfE5+z2g4YPbHfqhjVND=2xZKQ@mail.gmail.com>
References: <1388756813-10875-1-git-send-email-hkchu@google.com>
	<20140103.205131.1429670011198294911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:42733 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaADFU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 00:20:29 -0500
Received: by mail-qc0-f178.google.com with SMTP id i17so15444433qcy.37
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 21:20:28 -0800 (PST)
In-Reply-To: <20140103.205131.1429670011198294911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 4, 2014 at 9:51 AM, David Miller <davem@davemloft.net> wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Fri,  3 Jan 2014 05:46:53 -0800
>
>> +     if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +             NAPI_GRO_CB(skb)->csum = csum_sub(NAPI_GRO_CB(skb)->csum,
>> +                     csum_partial(start, len, 0));
>
> The csum_partial() call as argument needs to line up to exactly the
> first column after the openning parenthesis of the csum_sub()
> invocation.
>
> You must use the appropriate number of TAB then SPACE characters
> necessary to achieve this.
>
> If you indent only using TABS then likely you are doing it wrong :)

Yes I know but sometimes trying to line up arguments either causes > 80
column long line, or many shorter but highly indented fragmented lines
following.

I've fixed the above case and it worked (stopped at 79th column).

Jerry
