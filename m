From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 12:53:26 +0000
Message-ID: <20100902125326.GD8775@ff.dom.local>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net> <20100901145554.4f5abd80@nehalam> <20100902091839.GB6246@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38863 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab0IBMxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 08:53:35 -0400
Received: by bwz11 with SMTP id 11so521804bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 05:53:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100902091839.GB6246@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 09:18:39AM +0000, Jarek Poplawski wrote:
> On Wed, Sep 01, 2010 at 02:55:54PM -0700, Stephen Hemminger wrote:
> > On Wed, 01 Sep 2010 14:51:51 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Jarek Poplawski <jarkao2@gmail.com>
> > > Date: Mon, 30 Aug 2010 21:09:00 +0200
> > > 
> > > > On Mon, Aug 30, 2010 at 10:51:17AM -0700, Stephen Hemminger wrote:
> > > >> 
> > > >>  There's something very important I forgot to tell you.
> > > >>  What?
> > > >> 
> > > >>  Don't cross the GRO streams.
> > > >>  Why?
> > > >> 
> > > >>  It would be bad.
> > > >>  I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?
> > > >> 
> > > >>  Try to imagine all the Internet as you know it stopping instantaneously
> > > >>   and every bit in every packet swapping at the speed of light.
> > > >>  Total packet reordering.
> > > >>  Right. That's bad. Okay. All right. Important safety tip. Thanks, Hubert
> > > > 
> > > > Looks really bad to me, so... let's forget it! ;-) (At least until
> > > > next next.)
> > 
> > The patch wasn't that bad, but the movie quote probably confused you.
> 
> Yes, I was equally confused by both of them. Good to know it's only
> fiction... ;-)

Stephen, after Eric's explanation, I really think this patch was a bad
idea, and I apologize my false opinion started this.

I hope David, will revert this patch, please.

Sorry,
Jarek P.
