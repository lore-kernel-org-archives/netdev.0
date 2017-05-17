From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 net-next 4/7] net: add new control message for
 incoming HW-timestamped packets
Date: Wed, 17 May 2017 19:21:05 +0200
Message-ID: <20170517172105.GB9641@localhost.localdomain>
References: <20170516124425.6294-1-mlichvar@redhat.com>
 <20170516124425.6294-5-mlichvar@redhat.com>
 <CACSApvY=4DrURgQrx7AwFARO2Hbo63xXbq1ayUz_Rq9HuS5qmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36649 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754725AbdEQRVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 13:21:15 -0400
Received: by mail-wm0-f67.google.com with SMTP id k15so3754329wmh.3
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 10:21:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CACSApvY=4DrURgQrx7AwFARO2Hbo63xXbq1ayUz_Rq9HuS5qmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 10:11:50AM -0400, Soheil Hassas Yeganeh wrote:
> On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > +/* SCM_TIMESTAMPING_PKTINFO control message */
> > +struct scm_ts_pktinfo {
> > +       __u32 if_index;
> > +       __u32 pkt_length;
> > +};
> > +
> 
> Given that this structure can change in the future, it might be worth
> considering using TLVs (e.g., netlink attributes), similar to what
> tcp_get_timestamping_opt_stats() does. This would simplify
> adding/removing fields to/from the control message.

[ BTW, please trim your replies. ]

Personally, I dislike TLVs.  Alternatively, you could add some
reserved fields for future use.

Thanks,
Richard
