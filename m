From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3 net-next 1/2] af_packet: TX_RING support for TPACKET_V3
Date: Tue, 3 Jan 2017 10:57:23 -0500
Message-ID: <CAF=yD-L2b_x_tSt6ArjYqyvnM0FEz9gyBvbhPLUEqqZXtMpX-g@mail.gmail.com>
References: <cover.1483452545.git.sowmini.varadhan@oracle.com> <ad0b245b49761228a99b8865693c4a60550caf61.1483452545.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:36277 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758782AbdACP6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:58:04 -0500
Received: by mail-ua0-f195.google.com with SMTP id v2so17943680uac.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 07:58:04 -0800 (PST)
In-Reply-To: <ad0b245b49761228a99b8865693c4a60550caf61.1483452545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 9:31 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Although TPACKET_V3 Rx has some benefits over TPACKET_V2 Rx, *_v3
> does not currently have TX_RING support. As a result an application
> that wants the best perf for Tx and Rx (e.g. to handle request/response
> transacations) ends up needing 2 sockets, one with *_v2 for Tx and
> another with *_v3 for Rx.
>
> This patch enables TPACKET_V2 compatible Tx features in TPACKET_V3
> so that an application can use a single descriptor to get the benefits
> of _v3 RX_RING and _v2 TX_RING. An application may do a block-send by
> first filling up multiple frames in the Tx ring and then triggering a
> transmit. This patch only support fixed size Tx frames for TPACKET_V3,
> and requires that tp_next_offset must be zero.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Acked-by: Willem de Bruijn <willemb@google.com>
