From: Dan Williams <dcbw@redhat.com>
Subject: Re: Libertas related kernel crash
Date: Mon, 09 Nov 2009 23:04:25 -0800
Message-ID: <1257836665.19597.3.camel@localhost.localdomain>
References: <20091105120549.GQ14091@buzzloop.caiaq.de>
	 <20091109155354.GC14091@buzzloop.caiaq.de>
	 <1257835893.15493.37.camel@localhost.localdomain>
	 <20091110065457.GL14091@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, libertas-dev@lists.infradead.org,
	Michael Hirsch <m.hirsch@raumfeld.com>,
	linux-kernel@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428AbZKJHEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 02:04:36 -0500
In-Reply-To: <20091110065457.GL14091@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-10 at 07:54 +0100, Daniel Mack wrote:
> On Mon, Nov 09, 2009 at 10:51:33PM -0800, Dan Williams wrote:
> > On Mon, 2009-11-09 at 16:53 +0100, Daniel Mack wrote:
> > > On Thu, Nov 05, 2009 at 01:05:49PM +0100, Daniel Mack wrote:
> > > > On an ARM (PXA300) embdedded platform with a libertas chip connected via
> > > > SDIO, we happen to see the kernel Ooops below once in a while.
> > > > 
> > > > Any pointer on where to dig?
> > > 
> > > Some more input on this. Oopses similar to the one below are likely
> > > triggered when switching from Ad-hoc to managed mode multiple times in a
> > > row, and something seems corrupt the memory badly. I've searched for the
> > > obvious (double frees, out-of-bound writes etc), but I couldn't find
> > > anything yet. It is, however, related to the wireless core and/or the
> > > libertas driver.
> > 
> > Probably just libertas.  Any chance you can enable debugging options
> > (either in libertas, or in the kernel allocator) to help narrow down the
> > issue?
> 
> Sure. I already enabled DEBUG_VM, but that didn't spit out anything
> before it crashes. Which other debug flags would you recommend to set?

Offhand I don't actually know; but ISTR there used to be slab debugging
options in the kernel that could help find memory corruption issues.  I
can't think of anything in libertas offhand that would trigger this, but
maybe something is not getting properly cleaned up when switching modes?

Dan


