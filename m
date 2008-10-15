From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on powerpc
	selectsCONFIG_INTEL_IOATDMA=y
Date: Wed, 15 Oct 2008 13:23:51 +0530
Message-ID: <20081015075351.GA7925@linux.vnet.ibm.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
	<20081013112631.GD29938@cs181140183.pp.htv.fi>
	<36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
	<48F391B9.1000206@myri.com>
	<20081013183503.GA28133@cs181140183.pp.htv.fi>
	<48F4627E.30300@myri.com>
	<36D9DB17C6DE9E40B059440DB8D95F52066E36C7@orsmsx418.amr.corp.intel.com>
	<20081014175822.GA4710@cs181140183.pp.htv.fi>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Sosnowski,
	Maciej" <maciej.sosnowski@intel.com>,
	linux-kernel@vger.kernel.org, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, linuxppc-dev@ozlabs.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	sam@ravnborg.org, Jeff Garzik <jgarzik@redhat.com>,
	Brice Goglin <brice@myri.com>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20081014175822.GA4710@cs181140183.pp.htv.fi>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

* Adrian Bunk <bunk@kernel.org> [2008-10-14 20:58:22]:

> On Tue, Oct 14, 2008 at 09:10:33AM -0700, Brandeburg, Jesse wrote:
> > Brice Goglin wrote:
> > > Adrian Bunk wrote:
> > >> But considering that igb is in a similar situation it would be nice
> > >> if all 3 drivers would handle it the same way.
> > >> 
> > > 
> > > Jesse,
> > > What do you think of the below patch?
> > 
> > Seems like a much better solution.  I can have Jeff Kirsher work on the
> > equivalent patches for igb, and ixgbe today.
> > 
> > > I am not very familiar with Kconfig, but it seems to solve the
> > > problem. 
> > > If a Kconfig guru could double-check...
> > 
> > Yeah, please Kconfig gurus on the list have a quick look.
> 
> Brice's patch looks fine.
> 
> cu
> Adrian
> 

Thanks, the patch fixes the build failure with CONFIG_MYRI10GE=y, once
patch for CONFIG_IXGBE are send out by Jeff Kirsher/Jesse, I will retest
them.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
