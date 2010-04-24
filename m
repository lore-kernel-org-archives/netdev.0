From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Sat, 24 Apr 2010 11:36:29 +0100
Message-ID: <20100424113629.0ad3569b@linux.intel.com>
References: <20100423143356.7092.45260.stgit@localhost.localdomain>
	<20100423.163127.62645049.davem@davemloft.net>
	<20100423.163545.157549100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100423.163545.157549100.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2010 16:35:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Fri, 23 Apr 2010 16:31:27 -0700 (PDT)
> 
> > I'll apply this to net-2.6, thanks Alan.
> 
> Nevermind...
> 
> Doesn't apply to net-2.6, but even when I fix that up it doesn't
> even compile.  There is no 'dev' variable present etc.
> 
> You even use a combination of "dev" and "netdev" in the resulting
> code block.
> 
> If it doesn't even build, I doubt it's been tested either.

Puzzling as it came from a building -next tree. Will see whats happened
next week if I get time, but I'm afraid net stuff isn't a priority - in
fact its disappointing that having diagnosed a bug months ago (which
was the hard bit) and posted a test patch months ago the maintainers
haven't fixed it.

Alan

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
