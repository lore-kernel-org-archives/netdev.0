From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH net 0/4] xfrm_user info leaks
Date: Sat, 26 Aug 2017 21:56:34 +0200
Message-ID: <CA+rthh-k6QMZec2OBCT_BGR1w7M=SmgsA8jCKUtikPu4-1DK7A@mail.gmail.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com> <1503763138.12569.45.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:34993 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbdHZT4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 15:56:35 -0400
Received: by mail-yw0-f180.google.com with SMTP id s187so939867ywf.2
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 12:56:35 -0700 (PDT)
In-Reply-To: <1503763138.12569.45.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 August 2017 at 17:58, Joe Perches <joe@perches.com> wrote:
> On Sat, 2017-08-26 at 17:08 +0200, Mathias Krause wrote:
>> Hi David, Steffen,
>>
>> the following series fixes a few info leaks due to missing padding byte
>> initialization in the xfrm_user netlink interface.
>
> Were these found by inspection or by some tool?
> If by tool, perhaps there are other _to_user cases?

I found the one in the offload API by manual inspection, looked around
a little and found the others. No tool involved.

I already looked at the xfrm_user API back in 2012 and fixed quite a
few info leaks but missed the ones in the netlink multicast
notification code :/


Regards,
Mathias
