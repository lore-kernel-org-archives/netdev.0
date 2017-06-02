From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Cherry pick commit *net: better skb->sender_cpu and skb->napi_id
 cohabitation* to 4.4 series?
Date: Fri, 2 Jun 2017 10:51:39 -0700
Message-ID: <CAM_iQpXg3XCyfi7kStkWOh3R4+0yQHN15MOZ2dkbEYZvR1Xf2Q@mail.gmail.com>
References: <987d9047-08ac-0d53-2d1f-ef9189988ee2@molgen.mpg.de>
 <20170601.121935.1801387892378122014.davem@davemloft.net> <409abefe-62ff-563a-b5c6-a3149ae672e0@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        it+linux-netdev@molgen.mpg.de,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37192 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdFBRwB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 13:52:01 -0400
Received: by mail-wm0-f44.google.com with SMTP id d127so32512517wmf.0
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 10:52:00 -0700 (PDT)
In-Reply-To: <409abefe-62ff-563a-b5c6-a3149ae672e0@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 10:32 AM, Paul Menzel <pmenzel@molgen.mpg.de> wrote:
> Dear David,
>
>
> On 06/01/17 18:19, David Miller wrote:
>>
>> Neither of us have anything to do with the 4.4 -stable series.  We only
>> manage stable backport submissions for the most recent two releases.
>
>
> Thank you for the prompt response. Should the netdev FAQ be updated then to
> contain that information?

+1

It is quite helpful to know which stable releases contain network fixes
which don't, especially for those who rely on stable releases, at least
we could do backport by ourselves when we know they are missing.
