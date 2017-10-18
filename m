From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] tcp: socket option to set TCP fast open key
Date: Wed, 18 Oct 2017 13:37:27 -0700
Message-ID: <CANn89iK-dzwehweSZxVJ1z9YEYnhFMM3URYpARbxr4bUa1Nskg@mail.gmail.com>
References: <20171018182251.5486-1-ycheng@google.com> <20171018201344.GQ73751@Chimay.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yuchung Cheng <ycheng@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        "maheshb@google.com" <maheshb@google.com>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:49243 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdJRUh3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:37:29 -0400
Received: by mail-yw0-f170.google.com with SMTP id n189so1696983ywd.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:37:29 -0700 (PDT)
In-Reply-To: <20171018201344.GQ73751@Chimay.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 1:13 PM, Christoph Paasch <cpaasch@apple.com> wrote:
>
> Hello Yuchung,
>
> On 18/10/17 - 11:22:51, Yuchung Cheng wrote:
> > New socket option TCP_FASTOPEN_KEY to allow different keys per
> > listener.  The listener by default uses the global key until the
> > socket option is set.  The key is a 16 bytes long binary data. This
> > option has no effect on regular non-listener TCP sockets.
>
> can you explain what the use-case is to have per-listener TFO keys?
>

Security aspects. You want to be able to change keys whenever you
want, on an application basis.
