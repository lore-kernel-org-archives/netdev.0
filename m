From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] e1000: remove unused variables
Date: Sat, 29 Nov 2014 12:01:03 +0100
Message-ID: <5479A76F.5050809@gmx.de>
References: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
	<alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
	<20141127130725.GA12406@sudip-PC> <54790537.809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <54790537.809@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 29.11.2014 00:28, Florian Fainelli wrote:

> Also, if you do a read that is not stored in any return value, the
> compiler is now free to remove that actual read, 

This does not apply to reads from iomem (see "volatile" specifier in
readl()).

Regards,
Lino


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
