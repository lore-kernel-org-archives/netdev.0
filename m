From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Fri, 23 Apr 2010 12:20:42 -0400
Message-ID: <4BD1C8DA.4050002@garzik.org>
References: <20100423143356.7092.45260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100423143356.7092.45260.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 04/23/2010 10:34 AM, Alan Cox wrote:
> I'd assumed someone would have picked up on this and fixed it using rtnl_lock
> as was suggested but it seems to have fallen through the cracks ?
>
> Anyway this is I assume what was meant ?
>
> ---
>
> Nothing stops the workqueue being left to run in parallel with close or a
> few other operations. This causes double unmaps and the like.
>
> See kerneloops.org #1041230 for an example
>
> Signed-off-by: Alan Cox<alan@linux.intel.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>

Glad someone finally fixed this, it has bugged me for years...



------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
