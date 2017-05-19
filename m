From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v6 net-next 5/7] net: fix documentation of struct scm_timestamping
Date: Fri, 19 May 2017 11:59:23 -0400
Message-ID: <CAF=yD-KDtyyM=jwmQzf+kgDj-pR388DEjM4FZdTkWrs=0T5ddw@mail.gmail.com>
References: <20170519155241.15817-1-mlichvar@redhat.com> <20170519155241.15817-6-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35969 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756357AbdESQAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:00:04 -0400
Received: by mail-oi0-f66.google.com with SMTP id w138so13041959oiw.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:00:04 -0700 (PDT)
In-Reply-To: <20170519155241.15817-6-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 11:52 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> The scm_timestamping struct may return multiple non-zero fields, e.g.
> when both software and hardware RX timestamping is enabled, or when the
> SO_TIMESTAMP(NS) option is combined with SCM_TIMESTAMPING and a false
> software timestamp is generated in the recvmsg() call in order to always
> return a SCM_TIMESTAMP(NS) message.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Acked-by: Willem de Bruijn <willemb@google.com>
