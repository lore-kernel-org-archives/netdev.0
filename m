From: Neal Cardwell <ncardwell@google.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss > window)
Date: Wed, 18 Jan 2017 13:42:15 -0500
Message-ID: <CADVnQyms4+gXopm=Hyqq5iAMEuv3Nn-7fdri_d86j+jWs1bjKg@mail.gmail.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com> <3dbbcda8-ce79-641c-cf3b-21f41c563939@oracle.com>
 <CANn89iJn+fC-mMCskczXupj=yhvDijYEn-_NeCphuG8roNCygA@mail.gmail.com>
 <CAK6E8=fL+Gf_uqxALxX8iT7Ew9sxZA_+Ncaa+nh2ZWMkej154w@mail.gmail.com>
 <CANn89i+5E0nXEox0EHU7s3me00KegXNA4ZeKQWxQoWRC4jNbHQ@mail.gmail.com> <CAK6E8=cQdCvaXvcNzZYkC7R=vk2SmK7djS9OXNgqcWnO9CG0ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f179.google.com ([74.125.82.179]:36166 "EHLO
        mail-ot0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbdARSmr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 13:42:47 -0500
Received: by mail-ot0-f179.google.com with SMTP id 104so15076254otd.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 10:42:46 -0800 (PST)
In-Reply-To: <CAK6E8=cQdCvaXvcNzZYkC7R=vk2SmK7djS9OXNgqcWnO9CG0ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 1:27 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Hi Eric: yeah I think the test was just due to the TSO chunking
> difference between prod and upstream, which I was able to avoid with
> this patch re-suited by Neal in b/34128974. In fact, this patch
> enables me to run all recovery tests on upstream kernels for my RACK
> patch set.
>
> Neal: can we polish and check that in? super useful.

Yes, sounds good. Glad that was useful. I will work on polishing up
and checking in the patch to make packetdrill agnostic to TSO
segmentation by default (for upstream and Google).

neal
