From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 03/10] tcp: do not pass timestamp to tcp_rack_mark_lost()
Date: Tue, 25 Apr 2017 13:51:58 -0400
Message-ID: <CADVnQymkMctawba6ZZa2KBmSPVCvL+nL-xXjRvKp+zqoN_U6Vg@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-4-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:32793 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1429659AbdDYRw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:52:29 -0400
Received: by mail-oi0-f53.google.com with SMTP id y11so148766842oie.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:52:29 -0700 (PDT)
In-Reply-To: <20170425171541.3417-4-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> This is no longer used, since tcp_rack_detect_loss() takes
> the timestamp from tp->tcp_mstamp
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
