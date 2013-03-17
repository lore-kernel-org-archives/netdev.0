From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers:net: dma_alloc_coherent:
 use __GFP_ZERO instead of memset(, 0)
Date: Sun, 17 Mar 2013 12:50:42 -0400 (EDT)
Message-ID: <20130317.125042.778916600527811234.davem@davemloft.net>
References: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-kernel@vger.kernel.org, b43-dev@lists.infradead.org
To: joe@perches.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 15 Mar 2013 10:23:58 -0700

> Reduce the number of calls required to alloc
> a zeroed block of memory.
> 
> Trivially reduces overall object size.
> 
> Other changes around these removals
> o Neaten call argument alignment
> o Remove an unnecessary OOM message after dma_alloc_coherent failure
> o Remove unnecessary gfp_t stack variable
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good, applied, thanks Joe.

------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
