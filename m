From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Mon, 23 Jan 2012 19:03:35 -0800
Message-ID: <20120124030335.GA15514@kroah.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
 <CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com>
 <20120106050355.GA7633@kroah.com>
 <201201061200.44183.arnd@arndb.de>
 <CAOMZO5A9qpgAhL9NZXL3uYqSVjDPchdmBMySzjD=uenndjY4bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	gwingerde@gmail.com, larry.finger@lwfinger.net,
	davem@davemloft.net, bhutchings@solarflare.com,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54464 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932154Ab2AXDEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 22:04:13 -0500
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 44731217A5
	for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 22:04:13 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <CAOMZO5A9qpgAhL9NZXL3uYqSVjDPchdmBMySzjD=uenndjY4bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 12:57:36AM -0200, Fabio Estevam wrote:
> Hi Greg,
> 
> On Fri, Jan 6, 2012 at 10:00 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > I think that is true for the majority of stuff we have under drivers/misc
> > anyway. I had done the same patch that Fabio sent a couple of months ago
> > but then forgot about it, so here is a wholehearted
> >
> > Acked-by: Arnd Bergmann <arnd@arndb.de>
> >
> > for the new patch. It fixes a real problem, and we applied a similar patch
> > in drivers/mfd as 8a0a8e8e already. We probably still want to find a better
> > home for drivers that frequently get selected by other subsystems as you
> > said, but that is an independent issue. I don't see why anyone would
> > need a way to disable all MISC drivers at once, when the only thing that
> > (in theory) connects them is that they are all different from everything
> > else.
> 
> Do you have any objections about this patch?

Yes, I said my problems with it, I don't recall it being resent
afterward, with any changes.

greg k-h
