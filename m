From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 22:57:42 -0400
Message-ID: <CADVnQynTjLK6r2NyRiZzGbem-v_OPL9zih6Oz9V_cBEiVdW-1g@mail.gmail.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
 <1474342763-16715-17-git-send-email-ncardwell@google.com> <20160920114814.04f0f394@xeon-e3>
 <CADVnQym2JZk9naoygkwbMP5og7ZP+q5GgjxpWc8A3uMZzTwsaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36233 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755445AbcIUC6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:58:14 -0400
Received: by mail-oi0-f50.google.com with SMTP id t83so45135607oie.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:58:13 -0700 (PDT)
In-Reply-To: <CADVnQym2JZk9naoygkwbMP5og7ZP+q5GgjxpWc8A3uMZzTwsaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 2:50 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Tue, Sep 20, 2016 at 2:48 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>>
>> On Mon, 19 Sep 2016 23:39:23 -0400
>> Neal Cardwell <ncardwell@google.com> wrote:
>>
>> > +/* INET_DIAG_BBRINFO */
>> > +
>> > +struct tcp_bbr_info {
>> > +     /* u64 bw: max-filtered BW (app throughput) estimate in Byte per sec: */
>> > +     __u32   bbr_bw_lo;              /* lower 32 bits of bw */
>> > +     __u32   bbr_bw_hi;              /* upper 32 bits of bw */
>> > +     __u32   bbr_min_rtt;            /* min-filtered RTT in uSec */
>> > +     __u32   bbr_pacing_gain;        /* pacing gain shifted left 8 bits */
>> > +     __u32   bbr_cwnd_gain;          /* cwnd gain shifted left 8 bits */
>> > +};
>> > +
>>
>> I assume there is a change to iproute (ss) to dump this info?
>
> Yes, we have a patch for iproute2 (inet_diag.h and ss.c), which we've
> been using. We'll send that out ASAP.

Here are the patches with proposed iproute2 support to dump this info:

http://patchwork.ozlabs.org/patch/672538/
http://patchwork.ozlabs.org/patch/672539/
http://patchwork.ozlabs.org/patch/672540/

thanks,
neal
