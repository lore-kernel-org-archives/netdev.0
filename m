From: David Miller <davem@davemloft.net>
Subject: Re: packet received in a wrong rx-queue?
Date: Thu, 19 May 2011 23:12:54 -0400 (EDT)
Message-ID: <20110519.231254.2229327409525462171.davem@davemloft.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D7491A8@MILEXCH2.ds.jdsu.net>
	<20110518.233614.1134947771941589398.davem@davemloft.net>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F250D8853B7@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jon.Zhou@jdsu.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D8853B7@MILEXCH2.ds.jdsu.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Zhou <Jon.Zhou@jdsu.com>
Date: Thu, 19 May 2011 18:48:02 -0700

> Even that it gets different hash value, both packets should be delivered to same rx-queue,
> 
> Because they are belong to same flow?

That's not how it works.  They go to different queues, because the bits
are different for the flow keys in each direction.

I think we've brought this discussion to a conclusion, and that this
behavior is intentional.

Thank you.

------------------------------------------------------------------------------
What Every C/C++ and Fortran developer Should Know!
Read this article and learn how Intel has extended the reach of its 
next-generation tools to help Windows* and Linux* C/C++ and Fortran 
developers boost performance applications - including clusters. 
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
