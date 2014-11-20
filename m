From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [patch net-next] i40e: remove dead fdb code
Date: Thu, 20 Nov 2014 09:39:46 -0800
Message-ID: <20141120093946.00000d30@unknown>
References: <1416489029-1929-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	john.ronciak@intel.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1416489029-1929-1-git-send-email-jiri@resnulli.us>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 20 Nov 2014 14:10:29 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> This code is not used now and also it contains some weird ifdefs. So
> remove it for now. It can be added when needed.
> 

First, thanks for looking at our code.

but, NAK, the code just needs to have the #ifdefs removed.

In addition the fdb_del and fdb_dump functions are un-necessary and
were submitted by mistake.

I will draft up a patch today and send it (and Jeff can take it through
Jeff Kirsher's i40e tree, if thats okay with DaveM)

Thanks, 
 Jesse

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
