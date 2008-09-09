From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 05:19:45 -0700 (PDT)
Message-ID: <20080909.051945.161060171.davem@davemloft.net>
References: <20080909103137.GD31314@sirena.org.uk>
	<20080909.050500.200863990.davem@davemloft.net>
	<20080909120933.GE31314@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: broonie@sirena.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751606AbYIIMTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:19:52 -0400
In-Reply-To: <20080909120933.GE31314@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@sirena.org.uk>
Date: Tue, 9 Sep 2008 13:09:34 +0100

> On Tue, Sep 09, 2008 at 05:05:00AM -0700, David Miller wrote:
> > From: Mark Brown <broonie@sirena.org.uk>
> 
> > > FWIW the problem with this and some other mails you raised this on
> > > recently is that they're sent with format=folowed which tells the
> > > receiving MUA that it's OK to reflow the text to fit the display.
> 
> > I'll have to see why MEW isn't handling that correctly then,
> > it even claims to support this in the version I am using :)
> 
> Handling it correctly is probably the problem - if it's working as
> expected then when your window is wide enough to display lines longer
> than 80 columns it'll go ahead and reflow the text to fill the window.

I'm using a VC console screen ~160 characters long, and many lines
were wrapped instead of flowed.

Emacs puts a special character at the end of the line when it has to be
wrapped, and I saw those when viewing the mails in quesiton.

When I see that character when reading emails, my blood starts to boil :)
