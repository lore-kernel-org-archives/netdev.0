From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [RFC PATCH 6/7] net: allow simultaneous SW and HW transmit
 timestamping
Date: Thu, 13 Apr 2017 16:59:44 +0200
Message-ID: <20170413145944.GB7490@localhost>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-7-mlichvar@redhat.com>
 <CAF=yD-K2UTDt_um7F5WgwYMd5SYsiS0VMJpQ2MZM1oCfoFcjPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43359 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754480AbdDMO7r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 10:59:47 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-K2UTDt_um7F5WgwYMd5SYsiS0VMJpQ2MZM1oCfoFcjPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 10:30:32AM -0400, Willem de Bruijn wrote:
> On Wed, Apr 12, 2017 at 10:17 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > +SOF_TIMESTAMPING_OPT_MULTIMSG:
> > +
> > +  Allow outgoing packets to be looped multiple times to the socket's
> > +  error queue in order to receive both software and hardware transmit
> > +  timestamps.
> > +
> 
> It is already possible to receive multiple copies of the same message.
> Timestamps of type SCM_TSTAMP_SCHED will be passed for every
> device, virtual or physical, such as bonding. With TCP retransmits,
> multiple SCM_TSTAMP_SND can be observed.

Oh, I see. I was struggling to find a good name for this option.

> The name for this option is therefore not very descriptive. Perhaps
> SOF_TIMESTAMPING_OPT_BOTH_SW_HW.

Simultaneous SW/HW timestamping was already possible for incoming
packets. Maybe _OPT_TX_SWHW would be better?

-- 
Miroslav Lichvar
