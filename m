From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 05/10] tcp: do not pass timestamp to tcp_fastretrans_alert()
Date: Tue, 25 Apr 2017 13:52:45 -0400
Message-ID: <CADVnQyn3C_geYxM_4peWmUf4L1XUi34N2bZt=uQ3JEBWiS8=JA@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-6-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33880 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430191AbdDYRxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:53:16 -0400
Received: by mail-oi0-f52.google.com with SMTP id x184so181934534oia.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:53:16 -0700 (PDT)
In-Reply-To: <20170425171541.3417-6-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> Not used anymore now tp->tcp_mstamp holds the information.
>
> This is needed to remove sack_state.ack_time in a following patch.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
