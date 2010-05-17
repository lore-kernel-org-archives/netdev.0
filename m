From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [patch] pm_qos update fixing mmotm 2010-05-11
	-dies in pm_qos_update_request()
Date: Mon, 17 May 2010 23:58:00 +0200
Message-ID: <201005172358.00076.rjw@sisk.pl>
References: <20100515021922.GA5041@thegnar.org>
	<201005170021.25427.rjw@sisk.pl>
	<20100517001241.GA2962@thegnar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mgross@linux.intel.com, Valdis.Kletnieks@vt.eu,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, akpm@linux-foundation.org,
	davem@davemloft.net
To: markgross@thegnar.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100517001241.GA2962@thegnar.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Monday 17 May 2010, mgross wrote:
> On Mon, May 17, 2010 at 12:21:25AM +0200, Rafael J. Wysocki wrote:
> > On Saturday 15 May 2010, mgross wrote:
> > > On Sat, May 15, 2010 at 09:38:47PM +0200, Rafael J. Wysocki wrote:
> > > > On Saturday 15 May 2010, mgross wrote:
> > > > > I apologize for the goofy email address.  
> > > > > 
> > > > > The following is a fix for the crash reported by Valdis.
> > > > > 
> > > > > The problem was that the original pm_qos silently fails when a request
> > > > > update is passed to a parameter that has not been added to the list
> > > > > yet.  It seems that the e1000e is doing this.  This update restores this
> > > > > behavior.
> > > > > 
> > > > > I need to think about how to better handle such abuse, but for now this
> > > > > restores the original behavior.
> > > > 
> > > > Can you please post a signed-off incremental patch against
> > > > 
> > > > git://git.kernel.org/pub/scm/linux/kernel/git/rafael/suspend-2.6.git for-llinus
> > > > 
> > > > that contains your original PM QOS update?
> > > 
> > > No problem:
> > >
> > > Signed-off-by: markgross <markgross@thegnar.org>
> > 
> > Thanks!  Do you want to use this address for the sign-off or the Intel one?
> 
> I guess so.  Ever since switching groups within intel last summer my
> mgross@linux.intel.com address isn't checked as often as this one. 
> 
> The other option is to use my outlook email (mark.gross@intel.com), but
> I really hate posting from outlook.  Besides, doing upstream kernel
> stuff isn't my day job any more so using markgross@thegnar.org  makes
> sense to me.

Good.  Patch applied to suspend-2.6/for-linus.

Thanks,
Rafael

------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
