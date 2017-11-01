From: Joe Smith <codesoldier1@gmail.com>
Subject: Re: SKB Reference Question
Date: Wed, 1 Nov 2017 12:22:21 -0700
Message-ID: <CABGNecySKtpPb2VjqugXYLX4wif=f07nf=F3WZvfc4M0k4CJGA@mail.gmail.com>
References: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
 <1509557611.3828.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:48035 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKATWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 15:22:23 -0400
Received: by mail-lf0-f50.google.com with SMTP id k40so3722055lfi.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 12:22:22 -0700 (PDT)
In-Reply-To: <1509557611.3828.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 1, 2017 at 10:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Wed, 2017-11-01 at 10:27 -0700, Joe Smith wrote:
>> How strictly are references on the SKB enforced. For example,
>> tcp_transmit_skb() clones the SKB and adds a TCP header. Can I assume
>> that in case of re-transmission the header added will be there and can
>> be reused instead of creating a new one from scratch. Some fields like
>> time stamp would need to be updated but they should be unmodified.
>
>
> Not sure what you are trying to do, but this seems messy ;)

As an example, consider reusing options that might be expensive to
calculate. Assuming no coalescing.

>
> At rtx time, there is no guarantee that the master skb has not been
> changed, so the content of TCP header might be wrong anyway.

I would have thought that each layer below TCP would only add it=C5=9B own
header and would not touch anything else. Is that not the guarantee
that SKB references provide=C5=9B, or else the data could be changed.

Can you give an example why the TCP header could change.

Thanks a lot for your time.




>
>
>



--=20
JS
