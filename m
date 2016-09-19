From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 14:23:14 -0700
Message-ID: <CANn89iJXLkmLG8rjWA3rsC88-E1Q-hQRbXc2pgtuDK6eOoiz7g@mail.gmail.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-17-git-send-email-ncardwell@google.com> <20160919135734.04ab5172@xeon-e3>
 <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com> <9d2f75e6-0161-aa25-e362-ad7267ee2251@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:34073 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932329AbcISVXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:23:21 -0400
Received: by mail-yw0-f176.google.com with SMTP id g192so164124588ywh.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:23:21 -0700 (PDT)
In-Reply-To: <9d2f75e6-0161-aa25-e362-ad7267ee2251@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 2:17 PM, Rick Jones <rick.jones2@hpe.com> wrote:

>
> Are there better than epsilon odds of someone perhaps wanting to poke those
> values as it gets exposure beyond Google?
>

This does not matter.

A change would require patching net/ipv4/tcp_bbr.c , and the 'const'
attribute being there or not does not prevent the change.

I was simply asking to Stephen if the compiler would actually emit a
very different code, worth doing a last minute change.

The main BBR costs are divides and some multiplies , and they are
using per socket fields.
