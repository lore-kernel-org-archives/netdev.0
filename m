From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 0/3] WOL fixes for e1000e,
	e1000 and igb (was: Re: [Bugme-new] [Bug 11865] New: WOL for E100
	Doesn't Work Anymore)
Date: Tue, 4 Nov 2008 17:40:49 +0100
Message-ID: <200811041740.50426.rjw@sisk.pl>
References: <bug-11865-10286@http.bugzilla.kernel.org/>
	<F169D4F5E1F1974DBFAFABF47F60C10A0E873FEB@orsmsx507.amr.corp.intel.com>
	<200811040243.33386.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rogerx@sdf.lonestar.org" <rogerx@sdf.lonestar.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200811040243.33386.rjw@sisk.pl>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tuesday, 4 of November 2008, Rafael J. Wysocki wrote:
[--snip--]
> 
> > Your work is appeciated, I just didn't realize it would break all
> > devices that didn't implement it.
> 
> In fact it doesn't really break them, you can write 'enabled' to
> /sys/devices/.../power/wakeup of the device in question and it will work.
> 
> > I'm open to corrections to my point of view above.
> 
> Well, before those changes WOL didn't work on any of my machines and now
> it works on all of them (except for one that hasn't been tested) - with the
> already merged patches and the two waiting for merging.
> 
> Sorry about the problems caused, I'm willing to fix them ASAP.

BTW, WOL fixes for e1000e, e1000 and igb follow.

Thanks,
Rafael


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
