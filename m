From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v2 2/2] tcp: allow to turn tcp timestamp
 randomization off
Date: Thu, 1 Dec 2016 10:40:19 +0100
Message-ID: <20161201094019.GB17239@breakpoint.cc>
References: <1480508930-24406-1-git-send-email-fw@strlen.de>
 <1480508930-24406-2-git-send-email-fw@strlen.de>
 <CAK6E8=cntqXf7r5Vkce3DPYmNmrUZV5m=dC7kztDY0RFDsUtwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51456 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751606AbcLAJnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 04:43:23 -0500
Content-Disposition: inline
In-Reply-To: <CAK6E8=cntqXf7r5Vkce3DPYmNmrUZV5m=dC7kztDY0RFDsUtwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuchung Cheng <ycheng@google.com> wrote:
> > +tcp_timestamps - INTEGER
> > +Enable timestamps as defined in RFC1323.
> > +       0: Disabled.
> > +       1: Enable timestamps as defined in RFC1323.
> > +       2: Like 1, but also use a random offset for each connection
> > +       rather than only using the current time.
> > +       Default: 2
> Small suggestion: I suspect host/server configs manually set the knob
> to 1. Perhaps swap 1 and 2 to maximize the coverage of this new
> feature?

You mean:
1 (default): randomize
2: don't randomize?

I think its good idea, will send v3.  Thanks!
