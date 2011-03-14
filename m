From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 19:30:40 +0000
Message-ID: <1300131040.32696.23.camel@localhost.localdomain>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
	 <1300128035.2584.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:5127 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab1CNTbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:31:35 -0400
In-Reply-To: <1300128035.2584.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 18:40 +0000, Ben Hutchings wrote:
> On Mon, 2011-03-14 at 14:27 +0000, Ian Campbell wrote:
> > The following patch is the fifth iteration of the Xen network backend
> > driver for upstream Linux.
> > 
> > This driver ("netback") is the host side counterpart to the frontend
> > driver in drivers/net/xen-netfront.c. The PV protocol is also
> > implemented by frontend drivers in other OSes too, such as the BSDs and
> > even Windows.
> > 
> > Changes since the fourth posting, due to review from Stephen Hemminger:
> >       * Treat dev->features as u32 (it effectively is already and
> >         becomes literally so in net-next -- there's no harm in netback
> >         switching earlier)
> >       * Use stats from struct netdevice instead of a local copy.
> [...]
> 
> All looks good (or good enough) to me.

Thanks.

> I would add Reviewed-by, but this isn't a single patch.

Sure.

> I know you have asked for this to be pulled, in order to retain its
> history, but I'm not sure that David Miller will do this unless the
> driver is at least buildable at each stage in the history.  (However,
> given that the driver wouldn't be enabled before it's added, I'm not
> sure it matters in this case.)

I think it should be, at least from the second commit onwards (modulo
any mistakes made in the past).

To be sure perhaps I should rebase to add a depends BROKEN to (or
otherwise nobble) the Kconfig entry at the beginning of time and only
remove it at the end of the series?

I'd definitely like to keep the cleanups I made while upstreaming
separated from the version imported from xen.git though, but I could
collapse things before that point if that would be preferred. The
upstream/dom0/backend/netback-base branch is the imported version,
everything after that until upstream/dom0/backend/netback is what I
really want to keep as separate commits, the stuff before is just (very)
nice to have.

Ian.

