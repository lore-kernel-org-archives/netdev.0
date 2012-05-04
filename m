From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Fri, 4 May 2012 14:47:52 -0700
Message-ID: <20120504214752.GA9827@animalcreek.com>
References: <20120503160917.GA11310@animalcreek.com>
 <B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
 <20120503184632.GA28089@animalcreek.com>
 <B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
 <1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
 <87ehr1gdcv.fsf@ti.com>
 <B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
 <87fwbgdnlp.fsf@ti.com>
 <20120504182938.GB28910@animalcreek.com>
 <87397faccs.fsf@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>, nsekhar@ti.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Kevin Hilman <khilman@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87397faccs.fsf@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2012 at 02:02:43PM -0700, Kevin Hilman wrote:
> "Mark A. Greer" <mgreer@animalcreek.com> writes:
> 
> > On Fri, May 04, 2012 at 07:31:30AM -0700, Kevin Hilman wrote:
> 
> [...]
> 
> >> Come to think of it, the right solution here is probably to use runtime
> >> PM.  We could then to add some custom hooks for davinci_emac in the
> >> device code to use enable_hlt/disable_hlt based on activity.
> >
> > That was my first thought, actually, but that only works if its
> > okay for the driver to call enable_hlt/disable_hlt directly (i.e.,
> > have runtime_suspend() call enable_hlt() and runtime_resume() call
> > disable_hlt()).  However, I assumed it would _not_ be acceptable for
> > the driver to issue those calls directly.  
> 
> I agree.
> 
> > Its a platform-specific issue that we shouldn't be polluting the
> > driver with and there are currently no drivers that call them under
> > the drivers directory.
> 
> Using runtime PM we don't have to have any platform specific calls in
> the driver.  We handle it inside the platform-specific runtime PM
> implementation.

FYI, with some further discussion via IRC, I'm going to implement what
Kevin has laid out here.  There is a dependency on davinci adding support
too but I'll coordinate with the people/person doing that.

Please disregard this patch.

Thanks for the help everyone.

Mark
