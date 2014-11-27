From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] e1000: remove unused variables
Date: Thu, 27 Nov 2014 18:37:25 +0530
Message-ID: <20141127130725.GA12406@sudip-PC>
References: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
 <alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 26, 2014 at 09:59:28PM -0800, Hisashi T Fujinaka wrote:
> I'm pretty sure those double reads are there for a reason, so most of
> this I'm going to have to check on Monday. We have a long holiday
> weekend here in the US.

if the double reads are there for some reason, can you please let me know what that reason might be..

> 
> I'm not sure why you're bothering with an old driver like this, but if
> you haven't actually tried this on all the hardware it pertains to, I'm
> going want to NAK this.

no it has not been tested on hardware.  :(

i am still in the learning process, NAK is also part of learning.

infact there is another part of the code, which, theoretically, will never get executed. but i didnot dare to send that removal patch without testing on the hardware.

thanks
sudip

> 
> I should do this from my todd.fujinaka@intel.com account but it's 10PM
> on the first day of a long holiday weekend.
> 
> On Thu, 27 Nov 2014, Sudip Mukherjee wrote:
> 
> >these variables were only being assigned some values, but were never
> >used.
> >
> >Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> >---
> >drivers/net/ethernet/intel/e1000/e1000_hw.c   | 142 ++++++++++++--------------
<snip>
> >			case SPEED_100:
> >-				txb2b = false;
> >				/* maybe add some timeout factor ? */
> >				break;
> >			}
> >
> 
> -- 
> Hisashi T Fujinaka - htodd@twofifty.com
> BSEE + BSChem + BAEnglish + MSCS + $2.50 = coffee
