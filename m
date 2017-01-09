From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net-next 0/5] sctp: add support for generating stream
 reconf chunks
Date: Mon, 9 Jan 2017 17:04:24 -0200
Message-ID: <20170109190424.GE3781@localhost.localdomain>
References: <cover.1483781759.git.lucien.xin@gmail.com>
 <20170109124325.GB20973@hmswarspite.think-freely.org>
 <20170109.105301.469495957021068521.davem@davemloft.net>
 <CADvbK_dE74bAoTNo9gLczLuj71w3WMcPJ56tCFGJ=XjTMtTgRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758119AbdAITE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 14:04:28 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_dE74bAoTNo9gLczLuj71w3WMcPJ56tCFGJ=XjTMtTgRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 02:27:09AM +0800, Xin Long wrote:
> On Mon, Jan 9, 2017 at 11:53 PM, David Miller <davem@davemloft.net> wrote:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Mon, 9 Jan 2017 07:43:25 -0500
> >
> >> These all look reasonably good, but it seems before we accept them,
> >> there should be an additional patch that actually makes use of the code.
> >> I presume that is forthcomming?
> >
> > This all comes from my asking that the original huge set of patches be
> > split up.
> >
> > People always just rush this kind of work and never think about laying
> > out the resubmission properly.
> >
> > One should always only submit new interfaces along with an actual use
> > because only with a use can we properly review whether the new
> > interface is good or not.
> 
> I was trying to keep the same order with rfc, but it seems not a good
> idea, will resplit, thanks.

Not sure how much it can help but one idea it to split it into requester
and requested sides. Do the first patches/patchsets to make Linux able
to accept/handle requests, and then to issue requests.

  Marcelo
