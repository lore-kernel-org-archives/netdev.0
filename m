From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Wed, 14 Jun 2017 16:24:53 -0700
Message-ID: <CALx6S37sPyn2Za++taRnFy6LcQHx8_yBiS=p7j5X8fN-0j44Pg@mail.gmail.com>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
 <CALx6S36NPk4ZYCq1TzWoAdfOeK+ba2D79-giE7WOLeoVuYM_nw@mail.gmail.com> <20170614221738.GC72301@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        nmav@gnutls.org,
        =?UTF-8?B?RnJpZG9sw61uIFBva29ybsO9?= <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34276 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752121AbdFNXY4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 19:24:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id u101so3622690wrc.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 16:24:55 -0700 (PDT)
In-Reply-To: <20170614221738.GC72301@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 3:17 PM, Dave Watson <davejwatson@fb.com> wrote:
> On 06/14/17 01:54 PM, Tom Herbert wrote:
>> On Wed, Jun 14, 2017 at 11:36 AM, Dave Watson <davejwatson@fb.com> wrote:
>> > This series adds support for kernel TLS encryption over TCP sockets.
>> > A standard TCP socket is converted to a TLS socket using a setsockopt.
>> > Only symmetric crypto is done in the kernel, as well as TLS record
>> > framing.  The handshake remains in userspace, and the negotiated
>> > cipher keys/iv are provided to the TCP socket.
>> >
>> I don't see support for TLS receive path in the kernel, only the send
>> path. Am I missing something?
>
> Correct, this is only TX.  Since it sounds likely some hardware might
> only be able to offload TX, we decided to configure TX and RX
> separately.  Using the OpenSSL patches, it should be transparent to
> users even if only one side is offloaded.
>
> The software RX patches exist but haven't been polished up yet.

Thanks for the clarification, looking forward to RX patches also!

Tom
