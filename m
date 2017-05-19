From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v5 net-next 4/7] net: add new control message for
 incoming HW-timestamped packets
Date: Fri, 19 May 2017 12:04:28 +0200
Message-ID: <20170519100428.GC21003@localhost>
References: <20170518140738.19617-1-mlichvar@redhat.com>
 <20170518140738.19617-5-mlichvar@redhat.com>
 <CAF=yD-+FCccqtF0oeqeph=dvrUJ8Byd8q_uWqZk+zvxYYtC_Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55290 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755246AbdESKEb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 06:04:31 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+FCccqtF0oeqeph=dvrUJ8Byd8q_uWqZk+zvxYYtC_Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 04:20:53PM -0400, Willem de Bruijn wrote:
> On Thu, May 18, 2017 at 10:07 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > +SOF_TIMESTAMPING_OPT_PKTINFO:
> > +
> > +  Enable the SCM_TIMESTAMPING_PKTINFO control message for incoming
> > +  packets with hardware timestamps. The message contains struct
> > +  scm_ts_pktinfo, which supplies the index of the real interface which
> > +  received the packet and its length at layer 2. A valid (non-zero)
> > +  interface index will be returned only if CONFIG_NET_RX_BUSY_POLL is
> > +  enabled and the driver is using NAPI.
> 
> It is probably good to explicitly call out that the remaining two fields
> are reserved and undefined. To stress that applications cannot be
> overly pedantic and start failing if these become non-zero.

Ok. I'm adding "The struct contains also two other fields, but they
are reserved and undefined".

-- 
Miroslav Lichvar
