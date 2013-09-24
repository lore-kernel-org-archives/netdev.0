From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/10] intel: Remove extern from function
	prototypes
Date: Tue, 24 Sep 2013 15:22:26 -0700
Message-ID: <1380061346.17366.1.camel@joe-AO722>
References: <cover.1380056108.git.joe@perches.com>
	<5ccc921af41a862fe969809228f029035f851502.1380056108.git.joe@perches.com>
	<1380060449.2189.6.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Don, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Jesse
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1380060449.2189.6.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


On Tue, 2013-09-24 at 15:07 -0700, Jeff Kirsher wrote:
> On Tue, 2013-09-24 at 14:09 -0700, Joe Perches wrote:
> > There are a mix of function prototypes with and without extern
> > in the kernel sources.  Standardize on not using extern for
> > function prototypes.
> > 
> > Function prototypes don't need to be written with extern.
> > extern is assumed by the compiler.  Its use is as unnecessary as
> > using auto to declare automatic/local variables in a block.
> 
> So you are able to confirm that all compilers make this assumption
> correctly?  The initial reason for using extern was because not all
> compilers made the assumption or made it correctly.

No, I didn't bother.

Any current compilers already do make this assumption
valid as it's been part of the c spec since 1989 and
prototypes without extern already are the predominate
form in .h files for linux kernel sources.

Even in drivers/net/ethernet/intel/... there are more
prototypes without extern than with extern.




------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60133471&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
