From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] tcp: Enable TFO without a cookie on a per-socket basis
Date: Tue, 17 Oct 2017 04:00:01 -0700
Message-ID: <CANn89i+50uOGyyNKd8HMsPuZpmxFpsj28gHc7LAV_0BL9NpkEQ@mail.gmail.com>
References: <20171017063714.17346-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:54992 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753123AbdJQLAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 07:00:03 -0400
Received: by mail-qt0-f173.google.com with SMTP id z19so2501166qtg.11
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 04:00:02 -0700 (PDT)
In-Reply-To: <20171017063714.17346-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 11:37 PM, Christoph Paasch <cpaasch@apple.com> wrote:
> We already allow to enable TFO without a cookie by using the
> fastopen-sysctl and setting it to TFO_SERVER_COOKIE_NOT_REQD (0x200).
> This is safe to do in certain environments where we know that there
> isn't a malicous host (aka., data-centers).
>
> A server however might be talking to both sides (public Internet and
> data-center). So, this server would want to enable cookie-less TFO for
> the connections that go to the data-center while enforcing cookies for
> the traffic from the Internet.
>
> This patch exposes a socket-option to enable this (protected by
> CAP_NET_ADMIN).

Have you thought instead of a route attribute ?

CAP_NET_ADMIN restriction is not really practical IMO.
