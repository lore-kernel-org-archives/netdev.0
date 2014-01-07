From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Tue, 7 Jan 2014 14:55:34 -0800
Message-ID: <CAPshTCj+jXjvKCRdBPZYdxPQzTXqKUdF7x2DJE-fBjECVZfH6A@mail.gmail.com>
References: <1389118999-16359-1-git-send-email-hkchu@google.com>
	<20140107.162251.778631453084913688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f45.google.com ([209.85.128.45]:49859 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbaAGWzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 17:55:35 -0500
Received: by mail-qe0-f45.google.com with SMTP id 6so1054150qea.32
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 14:55:34 -0800 (PST)
In-Reply-To: <20140107.162251.778631453084913688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 1:22 PM, David Miller <davem@davemloft.net> wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Tue,  7 Jan 2014 10:23:19 -0800
>
>> From: Jerry Chu <hkchu@google.com>
>>
>> This patch built on top of Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
>> ("net-gro: Prepare GRO stack for the upcoming tunneling support") to add
>> the support of the standard GRE (RFC1701/RFC2784/RFC2890) to the GRO
>> stack. It also serves as an example for supporting other encapsulation
>> protocols in the GRO stack in the future.
>  ...
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> Reviewed-by: Eric Dumazet <edumazet@google.com>
>
> Applied, thanks.
>
> We really need to talk about what we want to happen with these GRO
> offloads when GRE is not configured into the kernel.
>
> Right now, the GRO offloads simply won't happen.
>

I hope I've understood this correctly but with Eric's recent patch
"gre_offload: statically build GRE offloading support", gre_offload.o
is always present in the kernel regardless of the GRE configuration
option. And gre_offload.o is all that's needed for GRE-GRO to happen.

Jerry
