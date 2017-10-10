From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Tue, 10 Oct 2017 15:11:21 -0400
Message-ID: <CAF=yD-J+Abjka9PViEFE6OhKOWf65UK1do5prYboFC+m+Tv1wA@mail.gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
 <20171009.205228.714368596112967819.davem@davemloft.net> <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
 <20171010.103918.358738948563291074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:55036 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbdJJTMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 15:12:02 -0400
Received: by mail-oi0-f47.google.com with SMTP id u130so46982981oib.11
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 12:12:02 -0700 (PDT)
In-Reply-To: <20171010.103918.358738948563291074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 1:39 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Tue, 10 Oct 2017 11:29:33 -0400
>
>> If there is a way to expose these stats through vhost_net directly,
>> instead of through tun, that may be better. But I did not see a
>> suitable interface. Perhaps debugfs.
>
> Please don't use debugfs, thank you :-)

Okay. I'll take a look at tracing for on-demand measurement.
