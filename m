From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] e1000e: Move e1000e_disable_aspm_locked() inside
 CONFIG_PM
Date: Wed, 22 Jul 2015 11:41:20 +1000
Message-ID: <1437529280.16792.9.camel@ellerman.id.au>
References: <1436846075-29366-1-git-send-email-mpe@ellerman.id.au>
	 <1436956216.13597.8.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Avargil, Raanan" <raanan.avargil@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, aaron.f.brown@intel.com,
	yanirx.lubetkin@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436956216.13597.8.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-15 at 03:30 -0700, Jeff Kirsher wrote:
> On Tue, 2015-07-14 at 13:54 +1000, Michael Ellerman wrote:
> > e1000e_disable_aspm_locked() is only used in __e1000_resume() which is
> > inside CONFIG_PM. So when CONFIG_PM=n we get a "defined but not used"
> > warning for e1000e_disable_aspm_locked().
> > 
> > Move it inside the existing CONFIG_PM block to avoid the warning.
> > 
> > Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> > ---
> >  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> NACK, this is already fixed in my next-queue tree.  Raanan submitted a
> patch back on July 6th to resolve this issue, see commit id
> a75787d2246a93d256061db602f252703559af65 in my dev-queue branch of my
> next-queue tree.

OK. I take it your next-queue is destined for 4.3, so we'll just have to suck
on the warning until then?

cheers
