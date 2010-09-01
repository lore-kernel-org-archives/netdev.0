From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Wed, 1 Sep 2010 14:55:54 -0700
Message-ID: <20100901145554.4f5abd80@nehalam>
References: <20100830.095012.233695092.davem@davemloft.net>
	<20100830105117.0f0cf140@nehalam>
	<20100830190900.GA3141@del.dom.local>
	<20100901.145151.93454549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43882 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab0IAVz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 17:55:56 -0400
In-Reply-To: <20100901.145151.93454549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Sep 2010 14:51:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 30 Aug 2010 21:09:00 +0200
> 
> > On Mon, Aug 30, 2010 at 10:51:17AM -0700, Stephen Hemminger wrote:
> >> 
> >>  There's something very important I forgot to tell you.
> >>  What?
> >> 
> >>  Don't cross the GRO streams.
> >>  Why?
> >> 
> >>  It would be bad.
> >>  I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?
> >> 
> >>  Try to imagine all the Internet as you know it stopping instantaneously
> >>   and every bit in every packet swapping at the speed of light.
> >>  Total packet reordering.
> >>  Right. That's bad. Okay. All right. Important safety tip. Thanks, Hubert
> > 
> > Looks really bad to me, so... let's forget it! ;-) (At least until
> > next next.)

The patch wasn't that bad, but the movie quote probably confused you.

Alternatively, the driver could keep track of "current GRO device"
and manually complete the GRO if the next packet changes
the current device.  But it didn't seem worth the effort.

-- 
