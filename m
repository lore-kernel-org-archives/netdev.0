From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 05/10] igbvf: reset netdevice
 addr_assign_type if changed
Date: Fri, 17 Feb 2012 16:01:04 -0500 (EST)
Message-ID: <20120217.160104.2216743770253883286.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-6-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, dkukawka@suse.de,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1329493411-25750-6-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:26 +0100

> Reset the state of addr_assign_type to NET_ADDR_PERM as soon as
> the MAC get changed via .ndo_set_mac_address.
> 
> v2: use bitops to reset addr_assign_type
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.

------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
