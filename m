From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Mon, 31 Jul 2017 13:22:22 -0700
Message-ID: <CANn89i+m4gSTevvMJMt_qOF7Q-ugqLm-jNh+2aKZDSXWR48Ouw@mail.gmail.com>
References: <20170727233117.29695-1-fw@strlen.de> <CADVnQym-aDwv-NhcwM5eTW4XQZcKMS+64-VwObKFxT5maT=TGg@mail.gmail.com>
 <CAK6E8=dyuurH4iT5qf0U=JgOEr3X=mDGtG69-KKz5uj6nFYvwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Neal Cardwell <ncardwell@google.com>,
        Florian Westphal <fw@strlen.de>,
        Netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, Lawrence Brakmo <brakmo@fb.com>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Van Jacobson <vanj@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36704 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdGaUWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 16:22:23 -0400
Received: by mail-yw0-f173.google.com with SMTP id u207so102641396ywc.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 13:22:23 -0700 (PDT)
In-Reply-To: <CAK6E8=dyuurH4iT5qf0U=JgOEr3X=mDGtG69-KKz5uj6nFYvwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 1:04 PM, Yuchung Cheng <ycheng@google.com> wrote:
> by the time these devices use 4.12 kernels they are likely powerful
> enough to make header prediction irrelevant...

Also note that TCP stack complexity has increased a lot, I seriously
doubt anyone could notice any difference.

On small devices, the major cost is the wakeup of the cpu to process
one frame before going back to idle...
