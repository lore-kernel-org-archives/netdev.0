From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [Xen-devel] Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 21:28:23 +0200
Message-ID: <20110119192823.GN2754@reaktio.net>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com> <1295455216.11126.39.camel@bwh-desktop> <1295459316.14981.3727.camel@zakaz.uk.xensource.com> <1295460304.11126.53.camel@bwh-desktop> <4D3738AB.60701@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:36120 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814Ab1AST2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 14:28:43 -0500
Content-Disposition: inline
In-Reply-To: <4D3738AB.60701@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 11:16:59AM -0800, Jeremy Fitzhardinge wrote:
> On 01/19/2011 10:05 AM, Ben Hutchings wrote:
> > Not in itself.  NAPI polling will run on the same CPU which scheduled it
> > (so wherever the IRQ was initially handled).  If the protocol used
> > between netfront and netback doesn't support RSS then RPS
> > <http://lwn.net/Articles/362339/> can be used to spread the RX work
> > across CPUs.
> 
> There's only one irq per netback which is bound to one (V)CPU at a
> time.  I guess we could extend it to have multiple irqs per netback and
> some way of distributing packet flows over them, but that would only
> really make sense if there's a single interface with much more traffic
> than the others; otherwise the interrupts should be fairly well
> distributed (assuming that the different netback irqs are routed to
> different cpus).
> 

Does "multiqueue" only work for NIC drivers (and frontend drivers),
or could it be used also for netback?

(afaik Linux multiqueue enables setting up multiple receive queues each having a separate irq.)

-- Pasi

