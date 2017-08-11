From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH net-next] net: skb_needs_check() removes CHECKSUM_NONE
 check for tx.
Date: Fri, 11 Aug 2017 10:29:55 +0800
Message-ID: <CAMDZJNWztTG5mRjes-FyaLJuB1gZ-bDBaN8wihgOr1Vp5MJdeQ@mail.gmail.com>
References: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
 <CAF=yD-JjaDFy4pOeJ5Lh2em9MgK6jjNxSfc5MkZZ=L6cu9be4Q@mail.gmail.com>
 <CAMDZJNUMdKvKLJGtwg-3dMf_CPiX56x5b17A8H3oW2m=fkWAUw@mail.gmail.com> <CAF=yD-+uW1RZLrdxaFaynf3n3gKqh12Ho6Nhx0oj9ZbZRN166g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37838 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752180AbdHKC35 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:29:57 -0400
Received: by mail-oi0-f68.google.com with SMTP id j194so2267756oib.4
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 19:29:56 -0700 (PDT)
In-Reply-To: <CAF=yD-+uW1RZLrdxaFaynf3n3gKqh12Ho6Nhx0oj9ZbZRN166g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem, because we change the CHECKSUM_NONE to CHECKSUM_UNNECESSARY
in skb_needs_check(), I can't revert 6e7bc478c9a0
("net: skb_needs_check() accepts CHECKSUM_NONE for tx").  I change it
directly and resubmit it.

On Fri, Aug 11, 2017 at 1:03 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Wed, Aug 9, 2017 at 6:02 PM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
>> Thanks for your work.
>
> You, too.
>
>> On Thu, Aug 10, 2017 at 2:30 AM, Willem de Bruijn
>> <willemdebruijn.kernel@gmail.com> wrote:
>>> On Wed, Aug 9, 2017 at 5:04 AM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
>>>> This patch reverts the commit 6e7bc478c9a0
>>>> ("net: skb_needs_check() accepts CHECKSUM_NONE for tx"),
>>>> because we removed the UFO support.
>>>>
>>>> Cc: Eric Dumazet <edumazet@google.com>
>>>> Cc: Willem de Bruijn <willemb@google.com>
>>>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
>>>
>>>
>>> I would wait until net is merged into net-next. This will cause a conflict.
>>>
>>> Also, while logically equivalent, it is not a real revert (as in `git
>>> revert $SHA1`) of that patch.
>>>
>>> Aside from those concerns, I agree that the original patch is no
>>> longer needed now that UFO is reverted.
>
> Please do resubmit the revert patch once net has been merged into net-next.
