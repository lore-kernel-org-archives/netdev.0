From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Wed, 18 Oct 2006 20:39:24 -0700 (PDT)
Message-ID: <20061018.203924.38710018.davem@davemloft.net>
References: <45345999.4000300@psc.edu>
	<20061016.223513.35356292.davem@davemloft.net>
	<4534CAF3.5000505@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48015
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423237AbWJSDjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:39:16 -0400
To: jheffner@psc.edu
In-Reply-To: <4534CAF3.5000505@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 Oct 2006 08:22:11 -0400

> That's actually how I originally coded it. :)  But then it occurred to 
> me that if you've already been waiting for a full clock tick, the 
> marginal CPU savings of waiting longer will not be great.  Which is why 
> I chose the value of 2 ticks so you're guaranteed to have waited at 
> least one full tick.

Fair enough, patch applied, thanks.

BTW, like some other's using Thunderbird to send patches,
lines with nothing but spaces are being corrupted into
fully empty lines.

In fact, in your patch some trailing whitespace of existing
code lines were also eliminated by Thunderbird, further
corrupting the patch.

I fixed this all up by hand, but please try to get this fixed
up for future submissions.

Thanks.
