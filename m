From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 13:09:34 +0100
Message-ID: <20080909120933.GE31314@sirena.org.uk>
References: <48C60FFC.8090109@redhat.com> <20080908.230221.101659829.davem@davemloft.net> <20080909103137.GD31314@sirena.org.uk> <20080909.050500.200863990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:2294 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbYIIMJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:09:38 -0400
Content-Disposition: inline
In-Reply-To: <20080909.050500.200863990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 05:05:00AM -0700, David Miller wrote:
> From: Mark Brown <broonie@sirena.org.uk>

> > FWIW the problem with this and some other mails you raised this on
> > recently is that they're sent with format=folowed which tells the
> > receiving MUA that it's OK to reflow the text to fit the display.

> I'll have to see why MEW isn't handling that correctly then,
> it even claims to support this in the version I am using :)

Handling it correctly is probably the problem - if it's working as
expected then when your window is wide enough to display lines longer
than 80 columns it'll go ahead and reflow the text to fill the window.
