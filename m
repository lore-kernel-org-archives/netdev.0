From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 19:47:08 +0200
Message-ID: <20130916174708.GG3188@1wt.eu>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com> <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu> <20130916175152.4e013457@skate> <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com> <20130916163937.GC3188@1wt.eu> <20130916164412.GD3188@1wt.eu> <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:39450 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab3IPRre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 13:47:34 -0400
Content-Disposition: inline
In-Reply-To: <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 10:24:05AM -0700, Ethan Tuttle wrote:
> I have not opened my mirabox - but sure, I'll open it up and try those
> other settings when I get a chance.

OK

> Also, you mentioned that you have SMP disabled in your kernel.  It
> looks like it's on in my .config.  Should I run a test with SMP
> disabled?

You may want to try but I wouldn't bet on this.

> I'm surprised that nobody else sees this crash given how easy it is
> for me to reproduce.  BTW, the 3.11 kernel I made with 702821f
> reverted has been humming along for days without issue.

I'll have to rebuild with your config and exact 3.11 to test again.
Can you check the packet rate of your ping flood to give an order of
magnitude so that we're sure to be in the same conditions ?

Willy
