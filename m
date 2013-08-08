From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: add server ip to encrypt cookie in fast open
Date: Thu, 8 Aug 2013 15:30:45 -0700
Message-ID: <CAK6E8=dvRNc2VhzQYyPmfZvrLA4K34HM1yCKQd+_WGyCTrYqjg@mail.gmail.com>
References: <1375995982-17862-1-git-send-email-ycheng@google.com> <1375998763.4004.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:58603 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966832Ab3HHWbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 18:31:07 -0400
Received: by mail-ie0-f175.google.com with SMTP id s9so2922822iec.20
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 15:31:06 -0700 (PDT)
In-Reply-To: <1375998763.4004.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 8, 2013 at 2:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-08-08 at 14:06 -0700, Yuchung Cheng wrote:
>> Encrypt the cookie with both server and client IPv4 addresses,
>> such that multi-homed server will grant different cookies
>> based on both the source and destination IPs. No client change
>> is needed since cookie is opaque to the client.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  include/net/tcp.h       |  3 ++-
>>  net/ipv4/tcp_fastopen.c | 13 ++++++-------
>>  net/ipv4/tcp_ipv4.c     | 10 +++++++---
>>  3 files changed, 15 insertions(+), 11 deletions(-)
>
> Reviewed-by: Eric Dumazet <edumazet@google.com>
>
> I presume this is net-next material ?
yes net-next is what I test on. thanks for pointing that out.
>
>
