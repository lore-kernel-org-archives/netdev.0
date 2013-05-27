From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: e1000e: 1 second spins in
	e1000_acquire_swflag_ich8lan?
Date: Sun, 26 May 2013 19:48:52 -0500
Message-ID: <20130527004851.GA3065@lintop>
References: <20130526164634.GA7241@lintop.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130526164634.GA7241@lintop.rgmadvisors.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, May 26, 2013 at 11:46:34AM -0500, Shawn Bohrer wrote:
> I guess I have two questions:  
> 
> 1) Do these need to be mdelays instead of msleeps?  It looks like in
> my case this is called from process context, but I didn't audit all of
> the callers of this function and maybe it can happen from interrupt
> context too?
> 
> 2) Any idea why I'm hitting this in the first place?

Well, as is probably expected doing a cold boot of the system fixed
the issue (a warm reboot did not), so I'm guessing the hardware was
simply in a bad state.  It seems a bit excessive to me that this code
can spin in the kernel for up to a second, and it appears on my system
it was doing this every two seconds.

--
Shawn

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
