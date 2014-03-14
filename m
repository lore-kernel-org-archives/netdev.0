From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: next-20140313 - build error in e1000e driver
Date: Fri, 14 Mar 2014 10:33:55 +0200
Message-ID: <20140314083354.GC5018@intel.com>
References: <59774.1394739168@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <59774.1394739168@turing-police.cc.vt.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 03:32:48PM -0400, Valdis Kletnieks wrote:
> My kernel has CONFIG_PM_SLEEP=n, which leads to hilarity...
> 
>   CC      drivers/net/ethernet/intel/e1000e/netdev.o
> drivers/net/ethernet/intel/e1000e/netdev.c:7079:13: error: 'e1000e_pm_suspend' undeclared here (not in a function)
>   .suspend = e1000e_pm_suspend,
>              ^
> drivers/net/ethernet/intel/e1000e/netdev.c:7080:13: error: 'e1000e_pm_resume' undeclared here (not in a function)
>   .resume  = e1000e_pm_resume,
>              ^
> make[5]: *** [drivers/net/ethernet/intel/e1000e/netdev.o] Error 1
> make[4]: *** [drivers/net/ethernet/intel/e1000e] Error 2
> make[3]: *** [drivers/net/ethernet/intel] Error 2
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> Commit 38a529b5d4 claims to fix a related issue, but doesn't seem to do
> so correctly.

It fixes it correctly. The problem is that it got broke again with
the following commit:

d392f8ddb8 e1000e: Refactor PM flows

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
