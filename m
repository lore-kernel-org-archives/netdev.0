From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: cwnd does not increase in TCP YeAH
Date: Mon, 5 Sep 2016 08:52:19 -0400
Message-ID: <CADVnQy=vPfq2ntggThQ=TZ8MKK5WpXPHMt+L+4FDo5JCD4TejA@mail.gmail.com>
References: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Artem Germanov <agermanov@anchorfree.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33107 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932119AbcIEMwu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 08:52:50 -0400
Received: by mail-oi0-f45.google.com with SMTP id y2so25629294oie.0
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 05:52:50 -0700 (PDT)
In-Reply-To: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 5, 2016 at 12:03 AM, Artem Germanov
<agermanov@anchorfree.com> wrote:
>
> Commit 76174004a0f19785a328f40388e87e982bbf69b9
> (tcp: do not slow start when cwnd equals ssthresh )
> introduced regression in TCP YeAH. Using 100ms delay 1% loss virtual
> ethernet link kernel 4.2 shows bandwidth ~500KB/s for single TCP
> connection and kernel 4.3 and above (including 4.8-rc4) shows bandwidth
> ~100KB/s.
>  That is caused by stalled cwnd when cwnd equals ssthresh. This patch
> fixes it by proper increasing cwnd in this case.
>
> Signed-off-by: Artem Germanov <agermanov@anchorfree.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
