From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Fri, 2 May 2014 15:03:37 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1405021500380.29834@pobox.suse.cz>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com> <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz> <530F0C4F.9030200@mellanox.com> <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz> <CAG4TOxMw4siOqtjXrgUDaw8yWqYgSG4d8PqGuJ62AZBrC2O2AA@mail.gmail.com>
 <531F1550.3080401@mellanox.com> <alpine.LNX.2.00.1404241900020.3265@pobox.suse.cz> <CAJZOPZKUWsgcNRNhVDM3EGpvVT834pfqkEZ_Z3NmCQJXkNuApg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Sagi Grimberg <sagig@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZKUWsgcNRNhVDM3EGpvVT834pfqkEZ_Z3NmCQJXkNuApg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Apr 2014, Or Gerlitz wrote:

> I sent you private note on Mar 19th saying "are you on track with this
> for 3.15? the merge window is coming soon and you have 99% of what you
> need -- lets get there" which seems to be the piece that fell between
> the cracks.

I probably failed to see the implication that you/Mellanox is expecting me 
to deliver the final patch, sorry for that.

> > probably because it wasn't clearly stated *who* will be preparing 
> > patch(es) that'd be implementing the ideas above. My understanding was 
> > that it'd be Mellanox, given that they basically own the driver,
> 
> to be precise partially own the mlx4 HW driver (Roland is the
> mlx4_core/ib author and maintainer, we are asking for few years to get
> co-maintainer hat there, no success so far)

I am of course completely unfamiliar with internal affairs as this, so 
it's not really appropriate for me to comment, but if hardware vendor is 
not able to obtain maintainership of the driver for its own HW, that seems 
to signal some serious issues.

> , the problem you have described can happen with any HW driver, but as 
> stated earlier, the suggested plan will fix ipoib and mlx4 and following 
> that more hw drivers can be enhanced to support that too.
> 
> >
> > have the best testing coverage compared to very very limited
> > testing coverage I can do, and will be pushing it upstream anyway.
> >
> > I believe all the above can be easily created on top of the original patch I sent.
> 
> Indeed, so will take a look next week and let you know if it works for me

Excellent, thanks a lot, looking forward to any updates on this.

Thanks again,

-- 
Jiri Kosina
SUSE Labs
