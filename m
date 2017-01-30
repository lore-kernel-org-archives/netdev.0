From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Mon, 30 Jan 2017 14:23:23 -0800
Message-ID: <CANn89iLUfp7Y+LkvZ80UsFEw8VZ23=F6_SDyPzpbyAvxxoNeLw@mail.gmail.com>
References: <20170130220942.19105-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>
To: Dimitris Michailidis <dmichail@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35232 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbdA3WYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 17:24:00 -0500
Received: by mail-io0-f169.google.com with SMTP id j18so118652972ioe.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 14:23:24 -0800 (PST)
In-Reply-To: <20170130220942.19105-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 2:09 PM, Dimitris Michailidis
<dmichail@google.com> wrote:
> ip6_make_flowlabel() determines the flow label for IPv6 packets. It's
> supposed to be passed a flow label, which it returns as is if non-0 and
> in some other cases, otherwise it calculates a new value.
>
> The problem is callers often pass a flowi6.flowlabel, which may also
> contain traffic class bits.

Do you have an idea which commit added this bug Dimitris ?

Thanks !
