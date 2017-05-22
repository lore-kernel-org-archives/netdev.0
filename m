From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] net: define PKTINFO timestamping option in all archs
Date: Sun, 21 May 2017 23:50:11 -0400
Message-ID: <CAF=yD-JNBj8MJNBq0cxwbAqLHQiEjRicZ3_bvT2ZSRhTBKJJ=A@mail.gmail.com>
References: <20170522033147.17264-1-willemdebruijn.kernel@gmail.com> <20170521.233552.1330381397679616478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36618 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756846AbdEVDux (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:50:53 -0400
Received: by mail-oi0-f65.google.com with SMTP id w138so20830854oiw.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 20:50:52 -0700 (PDT)
In-Reply-To: <20170521.233552.1330381397679616478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 21, 2017 at 11:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Sun, 21 May 2017 23:31:47 -0400
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> The newly introduced timestamping option SCM_TIMESTAMPING_PKTINFO
>> is defined in asm-generic/socket.h. Also define it in the architecture
>> specific versions.
>>
>> Fixes: aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> CC: Miroslav Lichvar <mlichvar@redhat.com>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> I pushed a fix for this about 15 minutes ago :-).

Thanks, David!

Then ignore this one. Apologies for not spotting this sooner.
