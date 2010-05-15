From: Tejun Heo <tj@kernel.org>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Sat, 15 May 2010 11:10:39 +0200
Message-ID: <4BEE650F.3080701@kernel.org>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>
	<4BED79EB.1000204@kernel.org>
	<1273857641.3057.20.camel@localhost.localdomain>
	<201005151026.20356.carsten.aulbert@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>, Matt Mackall <mpm@selenic.com>
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <201005151026.20356.carsten.aulbert@aei.mpg.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/15/2010 10:26 AM, Carsten Aulbert wrote:
> e.g. how can I re-enable the interface once I issued
> 
> echo 1 > /sys/devices/pci0000:00/0000:00:1c.4/0000:0d:00.0/remove

echo 1 > /sys/devices/pci0000:00/0000:00:1c.4/rescan

-- 
tejun

------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
