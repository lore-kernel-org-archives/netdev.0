From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH 0/5] net/packet: fix multiple overflow issues in ring buffers
Date: Tue, 28 Mar 2017 17:15:58 +0200
Message-ID: <CAAeHK+yzQaSZghcHCNLMxNx9XvKuLUXPA1oPN7LvUMi4H5fCtA@mail.gmail.com>
References: <cover.1490709552.git.andreyknvl@google.com> <CAF=yD-+Lx+=uXNSDPFRu0AGsaeTPsH=uuDvBdFQg=oH7vmuB6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34982 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752114AbdC1PQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:16:00 -0400
Received: by mail-pg0-f54.google.com with SMTP id 81so61074165pgh.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:15:59 -0700 (PDT)
In-Reply-To: <CAF=yD-+Lx+=uXNSDPFRu0AGsaeTPsH=uuDvBdFQg=oH7vmuB6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 5:06 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> This patchset addresses multiple overflows and signedness-related issues
>> in packet socket ring buffers.
>>
>> Andrey Konovalov (5):
>>   net/packet: fix overflow in check for priv area size
>>   net/packet: add explicit checks for tp_frame_size
>>   net/packet: fix overflow in check for tp_frame_nr
>>   net/packet: fix overflow in check for tp_reserve
>>   net/packet: reorder checks for ring buffer parameters
>
> These are a lot of changes to backport to stable kernels.
>
> Can we separate the minimal patch set needed to address known overflow
> to send to net (with annotation [PATCH net]) and follow up with the larger
> cleanup to net-next.

Sure, I can put patches 2 and 5 to a separate patchset.

>
>>
>>  net/packet/af_packet.c | 31 +++++++++++++++++++++----------
>>  1 file changed, 21 insertions(+), 10 deletions(-)
>>
>> --
>> 2.12.2.564.g063fe858b8-goog
>>
