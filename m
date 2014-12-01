From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] e1000: remove unused variables
Date: Mon, 1 Dec 2014 10:24:46 +0530
Message-ID: <20141201045446.GA3277@sudip-PC>
References: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
	<alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
	<1417311913.7215.111.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1417311913.7215.111.camel@decadent.org.uk>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, Nov 30, 2014 at 01:45:13AM +0000, Ben Hutchings wrote:
> On Wed, 2014-11-26 at 21:59 -0800, Hisashi T Fujinaka wrote:
> > I'm pretty sure those double reads are there for a reason, so most of
> > this I'm going to have to check on Monday. We have a long holiday
> > weekend here in the US.
> [...]
> 
> If there were double register reads being replaced with single register
> reads, I'd agree this was likely to introduce a regression.  But all I
> see is var = er32(REG) being changed to er32(REG).

no, double register reads are not modified. only the unused variables are removed.

thanks
sudip

> 
> Ben.
> 
> -- 
> Ben Hutchings
> The world is coming to an end.	Please log off.



------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
