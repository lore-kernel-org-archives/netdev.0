From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Subsystem/prefix in patch submission format
Date: Mon, 31 Jul 2006 06:27:36 +0200
Message-ID: <20060731042736.GA10597@mars.ravnborg.org>
References: <Pine.LNX.4.58.0607301342150.19037@kivilampi-30.cs.helsinki.fi> <20060730.152846.42906358.davem@davemloft.net> <20060730224543.GA9506@mars.ravnborg.org> <20060730.155956.106769160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:28833 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S1750906AbWGaE1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 00:27:47 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060730.155956.106769160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2006 at 03:59:56PM -0700, David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Mon, 31 Jul 2006 00:45:43 +0200
> 
> > >From a pure eye-candy perspective it would be nice to use same format
> > all over.
> > >From Documentation/SubmittingPatches:
> > ------------------
> > 12) The canonical patch format
> > 
> > The canonical patch subject line is:
> > 
> >     Subject: [PATCH 001/123] subsystem: summary phrase
> > --------------
> 
> The patch format specifies things that make no sense
> when the changes gets into the tree.  Especially the
> sequence numbers, which are implied by the changes
> placement in the relative changeset history.

"git am" removes the patch format specifiers when the change are
committed. git applymbox replace the patch format specifier with
[PATCH].

So:
git am        => subsystem: summary phrase
git applymbox => [PATCH] subsystem: summary phrase

Both variants exists because Linus uses the latter to distingush between
what is applied via git tress and what is applied via mail patches.

The Signed-off-by: carries same info btw.

	Sam
