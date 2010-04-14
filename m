From: Charles Slivkoff <slivkoff@cmu.edu>
Subject: Re: e1000e/netdev.c patch -- tx_ring->next_to_use
Date: Wed, 14 Apr 2010 14:47:58 -0400
Message-ID: <4BC60DDE.2060102@cmu.edu>
References: <4BC5E563.9050206@cmu.edu>
	<alpine.WNT.2.00.1004141105060.4368@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	"terry.loftin@hp.com" <terry.loftin@hp.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.1004141105060.4368@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 04/14/2010 02:12 PM, Brandeburg, Jesse wrote:
...

> have you filed a bug at launchpad?  if so what is the number?  I just want 
> to unite all the information we have.

I just submitted one, using "ubuntu-bug", so a number of associated 
system details are included as attachments.

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/563267

...

> As a workaround you can try disabling TSO using ethtool to see if that 
> helps.  We need to reproduce this here if possible.
> 
> ethtool -K eth0 tso off

I will give this a try.

> Do you happen to *not* have irqbalance installed or enabled?  I was 
> confused by the move_irq in one of the stack traces.  In any case it 
> probably doesn't matter but I was not expecting to see that there.

irqbalance is *not* installed.

...


Thanks,

-Charles


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
