From: Daniel Mack <daniel@caiaq.de>
Subject: Re: Libertas related kernel crash
Date: Tue, 10 Nov 2009 07:54:57 +0100
Message-ID: <20091110065457.GL14091@buzzloop.caiaq.de>
References: <20091105120549.GQ14091@buzzloop.caiaq.de>
 <20091109155354.GC14091@buzzloop.caiaq.de>
 <1257835893.15493.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, libertas-dev@lists.infradead.org,
	Michael Hirsch <m.hirsch@raumfeld.com>,
	linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751600AbZKJGy5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1257835893.15493.37.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 09, 2009 at 10:51:33PM -0800, Dan Williams wrote:
> On Mon, 2009-11-09 at 16:53 +0100, Daniel Mack wrote:
> > On Thu, Nov 05, 2009 at 01:05:49PM +0100, Daniel Mack wrote:
> > > On an ARM (PXA300) embdedded platform with a libertas chip connected via
> > > SDIO, we happen to see the kernel Ooops below once in a while.
> > > 
> > > Any pointer on where to dig?
> > 
> > Some more input on this. Oopses similar to the one below are likely
> > triggered when switching from Ad-hoc to managed mode multiple times in a
> > row, and something seems corrupt the memory badly. I've searched for the
> > obvious (double frees, out-of-bound writes etc), but I couldn't find
> > anything yet. It is, however, related to the wireless core and/or the
> > libertas driver.
> 
> Probably just libertas.  Any chance you can enable debugging options
> (either in libertas, or in the kernel allocator) to help narrow down the
> issue?

Sure. I already enabled DEBUG_VM, but that didn't spit out anything
before it crashes. Which other debug flags would you recommend to set?

Daniel
