From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3 net-next 3/7] net: add function to retrieve original
 skb device using NAPI ID
Date: Tue, 16 May 2017 18:29:39 -0400
Message-ID: <CAF=yD-L5JKJSaLGr_DwUKER-xEJ8ma2B2xSH93AQarP3gRcVvw@mail.gmail.com>
References: <20170516124425.6294-1-mlichvar@redhat.com> <20170516124425.6294-4-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33825 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdEPWaV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:30:21 -0400
Received: by mail-oi0-f65.google.com with SMTP id w10so5636769oif.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:30:20 -0700 (PDT)
In-Reply-To: <20170516124425.6294-4-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Since commit b68581778cd0 ("net: Make skb->skb_iif always track
> skb->dev") skbs don't have the original index of the interface which
> received the packet. This information is now needed for a new control
> message related to hardware timestamping.
>
> Instead of adding a new field to skb, we can find the device by the NAPI
> ID if it is available, i.e. CONFIG_NET_RX_BUSY_POLL is enabled and the
> driver is using NAPI. Add dev_get_by_napi_id() and also skb_napi_id() to
> hide the CONFIG_NET_RX_BUSY_POLL ifdef.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Suggested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Acked-by: Willem de Bruijn <willemb@google.com>
