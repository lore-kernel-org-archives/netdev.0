From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable
 transmits on shutdown
Date: Fri, 07 Mar 2014 13:54:41 -0500 (EST)
Message-ID: <20140307.135441.1623618469166033432.davem@davemloft.net>
References: <20140307020420.GA10797@amt.cnet>
	<1394162671.2214.36.camel@jtkirshe-mobl>
	<20140307151435.GB26026@amt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: VDavydov@parallels.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: mtosatti@redhat.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140307151435.GB26026@amt.cnet>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Marcelo Tosatti <mtosatti@redhat.com>
Date: Fri, 7 Mar 2014 12:14:35 -0300

> checkpatch.pl did not complain about those - feel free to fix them,
> thanks.

The problem is that GIT does when the maintainer applies your
patch.

You can sanity check your patch using GIT without commiting it
into the tree you are using by saying something like:

	git apply --check --whitespace=error-all $1

------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
