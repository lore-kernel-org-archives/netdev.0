From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] e100: power down PHY if WOL is not
	enabled
Date: Wed, 14 Dec 2011 22:07:48 +0000
Message-ID: <1323900468.2753.22.camel@bwh-desktop>
References: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
	<1323894636.2753.2.camel@bwh-desktop>
	<CEE05A0D7856E14880AD5560634EBEA82AA78720@365EXCH-MBX-P5.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Francis St. Amant" <Francis.St.Amant@riverbed.com>,
	Panchamukhi <Prasanna.Panchamukhi@riverbed.com>, Carolyn,
	"miles.ito@intel.com" <miles.ito@intel.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	John Ronciak <john.ronciak@intel.com>, Prasanna,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chaitanya Lala <Chaitanya.Lala@riverbed.com>, Peter
To: Jiang Wang <Jiang.Wang@riverbed.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CEE05A0D7856E14880AD5560634EBEA82AA78720@365EXCH-MBX-P5.nbttech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2011-12-14 at 21:59 +0000, Jiang Wang wrote:
> Hi Ben,
> 
> Do you mean the WOL is enabled but PHY is powered off somehow? That
> scenario should never happen. If WOL is enabled, there is no code to
> power off PHY.
[...]

Initial conditions: interface up, WOL off, PHY on.

1. Bring interface down. PHY is turned off.
2. Turn WOL on.  PHY is still off, but needs to be on.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Cloud Computing - Latest Buzzword or a Glimpse of the Future?
This paper surveys cloud computing today: What are the benefits? 
Why are businesses embracing it? What are its payoffs and pitfalls?
http://www.accelacomm.com/jaw/sdnl/114/51425149/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
