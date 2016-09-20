From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 14:50:39 -0400
Message-ID: <CADVnQym2JZk9naoygkwbMP5og7ZP+q5GgjxpWc8A3uMZzTwsaQ@mail.gmail.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
 <1474342763-16715-17-git-send-email-ncardwell@google.com> <20160920114814.04f0f394@xeon-e3>
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
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36481 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932640AbcITSvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 14:51:10 -0400
Received: by mail-oi0-f43.google.com with SMTP id t83so33035562oie.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 11:51:10 -0700 (PDT)
In-Reply-To: <20160920114814.04f0f394@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 2:48 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> On Mon, 19 Sep 2016 23:39:23 -0400
> Neal Cardwell <ncardwell@google.com> wrote:
>
> > +/* INET_DIAG_BBRINFO */
> > +
> > +struct tcp_bbr_info {
> > +     /* u64 bw: max-filtered BW (app throughput) estimate in Byte per sec: */
> > +     __u32   bbr_bw_lo;              /* lower 32 bits of bw */
> > +     __u32   bbr_bw_hi;              /* upper 32 bits of bw */
> > +     __u32   bbr_min_rtt;            /* min-filtered RTT in uSec */
> > +     __u32   bbr_pacing_gain;        /* pacing gain shifted left 8 bits */
> > +     __u32   bbr_cwnd_gain;          /* cwnd gain shifted left 8 bits */
> > +};
> > +
>
> I assume there is a change to iproute (ss) to dump this info?

Yes, we have a patch for iproute2 (inet_diag.h and ss.c), which we've
been using. We'll send that out ASAP.

thanks,
neal
