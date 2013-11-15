From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/4] wl1251: split wl251 platform data to a separate
 structure
Date: Fri, 15 Nov 2013 09:32:55 -0500
Message-ID: <20131115143254.GA7079@tuxdriver.com>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-2-git-send-email-sre@debian.org>
 <20131114185132.GQ10317@atomide.com>
 <20131114230330.GB6383@earth.universe>
 <20131114232217.GV10317@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luciano Coelho <luca@coelho.fi>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Felipe Balbi <balbi@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luciano Coelho <coelho@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131114232217.GV10317@atomide.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 03:22:18PM -0800, Tony Lindgren wrote:
> * Sebastian Reichel <sre@debian.org> [131114 15:04]:
> > On Thu, Nov 14, 2013 at 10:51:33AM -0800, Tony Lindgren wrote:
> > > [...]
> > >
> > > If this is not going into v3.13, these will cause conflicts
> > > with the mach-omap2/board-*.c files for v3.14.
> > > 
> > > So it might be best to do a minimal header patch first that
> > > can be merged in by both linux-omap and wireless trees.
> > 
> > I guess this patch is pretty minimal. It also seems to be acked by
> > the involved Maintainers, so maybe just merge Patch 1 without the
> > other patches?
> > 
> > This does not solve the problem with the struct modification from
> > the second patch, but I guess it's the more intrusive patch.
> 
> Once at least the first two patches are ready, how about I queue
> them after -rc1 and set up an immutable branch that can be merged
> in by linux-omap tree and the wireless tree?

That sounds reasonable to me.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
