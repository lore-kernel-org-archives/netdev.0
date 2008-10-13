From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on
	powerpc	selectsCONFIG_INTEL_IOATDMA=y
Date: Mon, 13 Oct 2008 21:35:03 +0300
Message-ID: <20081013183503.GA28133@cs181140183.pp.htv.fi>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
	<20081013112631.GD29938@cs181140183.pp.htv.fi>
	<36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
	<48F391B9.1000206@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, linuxppc-dev@ozlabs.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	apw@shadowen.org, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	sam@ravnborg.org, Jeff Garzik <jgarzik@redhat.com>
To: Brice Goglin <brice@myri.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <48F391B9.1000206@myri.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Oct 13, 2008 at 08:21:45PM +0200, Brice Goglin wrote:
> Brandeburg, Jesse wrote:
> > What we want, is myri10ge and ixgbe drivers that can build whether or not CONFIG_INTEL_IOATDMA is enabled.  IF CONFIG_INTEL_IOATDMA *is* enabled (which it should not be on PPC) then there are several cases we want to work:
> > CONFIG_INTEL_IOATDMA=m  ---> CONFIG_IXGBE=[m|n]
> > CONFIG_INTEL_IOATDMA=y  ---> CONFIG_IXGBE=[m|y|n]
> > CONFIG_INTEL_IOATDMA=n  ---> CONFIG_IXGBE=[m|y|n]
> > CONFIG_INTEL_IOATDMA depends on X86
> 
> I am not sure I want to prevent myri10ge=y just because ioatdma=m.
>...

Technically both solutions are possible, which to choose is just a 
policy decision you have to agree on.

In practice it will anyway only rarely matter.

But considering that igb is in a similar situation it would be nice if 
all 3 drivers would handle it the same way.

> Brice

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
