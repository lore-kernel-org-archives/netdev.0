From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data ACKed/SACKed
Date: Fri, 4 Aug 2017 14:01:34 -0400
Message-ID: <CADVnQymnVwT30EzVvTfZ0EX_6ehRom1W8Yt2Z5SQHhmWO+e+sw@mail.gmail.com>
References: <20170801025814.31206-1-ncardwell@google.com> <20170801025814.31206-4-ncardwell@google.com>
 <F95AC9340317A84688A5F0DF0246F3F2029373BA@DGGEMI512-MBX.china.huawei.com>
 <CADVnQykAKkb7KDhM03HHOHk8Uk7rMfXcyaLsHMLZRVT_g69euA@mail.gmail.com> <20170804171000.GB5342@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: maowenan <maowenan@huawei.com>, David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:34981 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdHDSCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 14:02:06 -0400
Received: by mail-qt0-f170.google.com with SMTP id p3so13404561qtg.2
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 11:02:06 -0700 (PDT)
In-Reply-To: <20170804171000.GB5342@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 4, 2017 at 1:10 PM, Willy Tarreau <w@1wt.eu> wrote:
> Hi Neal,
>
> On Fri, Aug 04, 2017 at 12:59:51PM -0400, Neal Cardwell wrote:
>> I have attached patches for this fix rebased on to v3.10.107, the
>> latest stable release for 3.10. That's pretty far back in history, so
>> there were substantial conflict resolutions and adjustments required.
>> :-) Hope that helps.
>
> At least it will help me :-)
>
> Do you suggest that I queue them for 3.10.108, that I wait for Maowenan
> to test them more broadly first or anything else ?

Let's wait for Maowenan to test them first.

Thanks!

neal
