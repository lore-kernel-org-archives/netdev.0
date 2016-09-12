From: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
Subject: Re: [PATCH 00/26] constify local structures
Date: Mon, 12 Sep 2016 21:50:23 +0300
Message-ID: <20160912185023.GB14727@intel.com>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
 <20160911172105.GB5493@intel.com>
 <alpine.DEB.2.10.1609121051050.3049@hadrien>
 <20160912131625.GD957@intel.com>
 <877fah5j35.fsf@linux.intel.com>
 <alpine.DEB.2.10.1609121548200.29099@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felipe Balbi <felipe.balbi@linux.intel.com>,
        linux-renesas-soc@vger.kernel.org, joe@perches.com,
        kernel-janitors@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        linux-pm@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-media@vger.kernel.org, linux-can@vger.kernel.org,
        Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
        Shiraz Saleem <shiraz.saleem@intel.com>,
        Mustafa Ismail <mustafa.ismail@intel.com>,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, alsa-devel@alsa-project.org,
        linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        tpmdd-devel@lists.sourceforge.net, linux-scsi@
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1609121548200.29099@hadrien>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 03:52:08PM +0200, Julia Lawall wrote:
> 
> 
> On Mon, 12 Sep 2016, Felipe Balbi wrote:
> 
> >
> > Hi,
> >
> > Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com> writes:
> > > On Mon, Sep 12, 2016 at 10:54:07AM +0200, Julia Lawall wrote:
> > >>
> > >>
> > >> On Sun, 11 Sep 2016, Jarkko Sakkinen wrote:
> > >>
> > >> > On Sun, Sep 11, 2016 at 03:05:42PM +0200, Julia Lawall wrote:
> > >> > > Constify local structures.
> > >> > >
> > >> > > The semantic patch that makes this change is as follows:
> > >> > > (http://coccinelle.lip6.fr/)
> > >> >
> > >> > Just my two cents but:
> > >> >
> > >> > 1. You *can* use a static analysis too to find bugs or other issues.
> > >> > 2. However, you should manually do the commits and proper commit
> > >> >    messages to subsystems based on your findings. And I generally think
> > >> >    that if one contributes code one should also at least smoke test changes
> > >> >    somehow.
> > >> >
> > >> > I don't know if I'm alone with my opinion. I just think that one should
> > >> > also do the analysis part and not blindly create and submit patches.
> > >>
> > >> All of the patches are compile tested.  And the individual patches are
> > >
> > > Compile-testing is not testing. If you are not able to test a commit,
> > > you should explain why.
> >
> > Dude, Julia has been doing semantic patching for years already and
> > nobody has raised any concerns so far. There's already an expectation
> > that Coccinelle *works* and Julia's sematic patches are sound.
> >
> > Besides, adding 'const' is something that causes virtually no functional
> > changes to the point that build-testing is really all you need. Any
> > problems caused by adding 'const' to a definition will be seen by build
> > errors or warnings.
> >
> > Really, just stop with the pointless discussion and go read a bit about
> > Coccinelle and what semantic patches are giving you. The work done by
> > Julia and her peers are INRIA have measurable benefits.
> >
> > You're really making a thunderstorm in a glass of water.
> 
> Thanks for the defense, but since a lot of these patches torned out to be
> wrong, due to an incorrect parse by Coccinelle, combined with an
> unpleasantly lax compiler, Jarkko does have a point that I should have
> looked at the patches more carefully.  In any case, I have written to the
> maintainers relevant to the patches that turned out to be incorrect.

Exactly. I'm not excepting that every commit would require extensive
analysis but it would be good to quickly at least skim through commits
and see if they make sense (or ask if unsure) :) 

And I'm fine with compile testing if it is mentioned in the commit msg.

> julia

/Jarkko
