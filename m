From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 14:10:39 -0700
Message-ID: <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-17-git-send-email-ncardwell@google.com> <20160919135734.04ab5172@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f180.google.com ([209.85.213.180]:35547 "EHLO
        mail-yb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751987AbcISVKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:10:40 -0400
Received: by mail-yb0-f180.google.com with SMTP id d69so95035162ybf.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:10:40 -0700 (PDT)
In-Reply-To: <20160919135734.04ab5172@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 1:57 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:

> Looks good, but could I suggest a simple optimization.
> All these parameters are immutable in the version of BBR you are submitting.
> Why not make the values const? And eliminate the always true long-term bw estimate
> variable?
>

We could do that.

We used to have variables (aka module params) while BBR was cooking in
our kernels ;)

Are you sure generated code is indeed 'optimized' ?
