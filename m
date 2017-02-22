From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 17:29:39 -0800
Message-ID: <20170221172939.432b9c9b@cakuba.netronome.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
        <20170221150907.5ae68ffa@cakuba.netronome.com>
        <CALx6S34aOhKt7JS=3tbweMm1pf3gnr4WU1ZnjOUc5-wP+xCuyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:34682 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753708AbdBVBaP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 20:30:15 -0500
In-Reply-To: <CALx6S34aOhKt7JS=3tbweMm1pf3gnr4WU1ZnjOUc5-wP+xCuyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Feb 2017 16:25:15 -0800, Tom Herbert wrote:
> >>   - Provides a more structured environment that is extensible to new
> >>     features while being mostly transparent to the drivers  
> >
> > So far all features we added required explicit driver support.
> > Checksumming support as an example will require driver changes, too.
> > Generalized way to call programs is probably not going to buy us much?
> >  
> Hi Jakub,
> 
> What is the the concern with checksumming? Isn't that just an issue of
> defining fields in xdp_data and driver populating with the appropriate
> information?

Thanks for replying!  I was just using checksumming as an example.  I
was trying to counter the argument that the hook infrastructure will
allow for features to be implemented mostly transparently to the
drivers.  I may be wrong but it seems that it doesn't buy us anything
as far as the features which were so far discussed go.
