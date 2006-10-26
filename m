From: Greg KH <gregkh@suse.de>
Subject: Re: Fwd: [PATCH] bcm43xx: (hopefully) fix watchdog timeouts.
Date: Wed, 25 Oct 2006 21:03:52 -0700
Message-ID: <20061026040352.GB7297@suse.de>
References: <200610241631.18911.mb@bu3sch.de> <20061025003726.GC7340@tuxdriver.com> <200610251138.39036.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:31906 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1422901AbWJZEFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 00:05:34 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610251138.39036.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 11:38:38AM +0200, Michael Buesch wrote:
> On Wednesday 25 October 2006 02:37, John W. Linville wrote:
> > Michael,
> > 
> > It looks like you have a patch that I don't have, one that moves the
> > netif_tx_disable and spin_lock_irqsave outside of the "if (badness >
> > BADNESS_LIMIT)" conditional.
> > 
> > Could you pass that one along as well, or correct this patch to match
> > what is in Linus' tree?
> 
> Well, I'm not sure who moved the tx_disable outside of the
> conditional. It is not needed. We only need to disable TX on
> the slowpath (the first branch of the if condition). It does not
> hurt to disable it always, though.
> But I will send a new patch against wireless-2.6, which only disables
> TX for the slowpath and fakes a TX there.
> 
> But for Greg, the original patch is ok.
> How was the stable mailing list again? stable@vger.kernel.org seems to bounce.

As per the MAINTAINERS file, it is stable@kernel.org

Please send this there, it will not get lost that way.

thanks,

greg k-h
