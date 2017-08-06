From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data ACKed/SACKed
Date: Sun, 6 Aug 2017 11:21:01 -0400
Message-ID: <CADVnQym4vWSK-t8hTe5W7ryi6kYBRPTyQomg9frofoMyAiTQiw@mail.gmail.com>
References: <20170801025814.31206-1-ncardwell@google.com> <20170801025814.31206-4-ncardwell@google.com>
 <F95AC9340317A84688A5F0DF0246F3F2029373BA@DGGEMI512-MBX.china.huawei.com>
 <CADVnQykAKkb7KDhM03HHOHk8Uk7rMfXcyaLsHMLZRVT_g69euA@mail.gmail.com>
 <20170804171000.GB5342@1wt.eu> <CADVnQymnVwT30EzVvTfZ0EX_6ehRom1W8Yt2Z5SQHhmWO+e+sw@mail.gmail.com>
 <20170804181854.GA5478@1wt.eu> <F95AC9340317A84688A5F0DF0246F3F202940EA5@DGGEMI512-MBX.china.huawei.com>
 <20170806074435.GA13300@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: maowenan <maowenan@huawei.com>, David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:37800 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdHFPVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 11:21:32 -0400
Received: by mail-qk0-f173.google.com with SMTP id z18so29366236qka.4
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 08:21:32 -0700 (PDT)
In-Reply-To: <20170806074435.GA13300@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 6, 2017 at 3:44 AM, Willy Tarreau <w@1wt.eu> wrote:
>
> On Sun, Aug 06, 2017 at 07:39:57AM +0000, maowenan wrote:
> >
> > [Mao Wenan]It works well with these patches of v3.10, and the
> > retransmission packet is about 250ms after TLP probe.
> > Thank you very much for these patches under 3.10.

Great. Thanks for testing those patches!

> Thanks, I'll take them then.

And thanks for applying the patches to 3.10.y!

neal
