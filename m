From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] rename dev_hw_addr_random and remove
 redundant second
Date: Mon, 13 Feb 2012 00:50:11 -0500 (EST)
Message-ID: <20120213.005011.1860393880116915900.davem@davemloft.net>
References: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
	<1328816934-11508-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, dkukawka@suse.de
To: danny.kukawka@bisect.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1328816934-11508-3-git-send-email-danny.kukawka@bisect.de>
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
Date: Thu,  9 Feb 2012 20:48:54 +0100

> Renamed dev_hw_addr_random to eth_hw_addr_random() to reflect that
> this function only assign a random ethernet address (MAC). Removed
> the second parameter (u8 *hwaddr), it's redundant since the also
> given net_device already contains net_device->dev_addr.
> Set it directly.
> 
> Adapt igbvf and ixgbevf to the changed function.
> 
> Small fix for ixgbevf_probe(): if ixgbevf_sw_init() fails
> (which means the device got no dev_addr) handle the error and
> jump to err_sw_init as already done by igbvf in similar case.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.

------------------------------------------------------------------------------
Try before you buy = See our experts in action!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-dev2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
