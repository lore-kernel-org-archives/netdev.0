From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Sat, 15 Oct 2011 11:52:22 +0800
Message-ID: <CAJFZqHyvu5419zaJ6Ro+s2d06LZ3mBqbAPuGF=3K6JAUK_vHqA@mail.gmail.com>
References: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
	<20111014.034822.2255593021765068562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:60969 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907Ab1JODwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 23:52:22 -0400
Received: by pzk1 with SMTP id 1so6934306pzk.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 20:52:22 -0700 (PDT)
In-Reply-To: <20111014.034822.2255593021765068562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/14 David Miller <davem@davemloft.net>:
> From: roy.qing.li@gmail.com
> Date: Fri, 14 Oct 2011 15:39:30 +0800
>
>> when pskb_expand_head reallocates header of &sk_buff, the sk
>> truesize should be updated simultaneously
>>
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>
> I know you did not test this patch at all.
>
> You can't modify the truesize because packets passed to this routine
> are often attached to a socket, thus if you change the truesize the
> socket memory accouting will be adjusted incorrectly later when the
> SKB is freed up.
>
> Most SKB modifying functions have to operate with this restriction.
>
>

I am sorry I do not know how to test it in fact.

But I believe the adjustment is right here
About incorrectly impact on socket, I am consider it, but I still no
idea about it.

Thanks.
