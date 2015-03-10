From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast
 promiscuous control
Date: Tue, 10 Mar 2015 03:01:45 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E53D11@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E53671@BPXM14GP.gisp.nec.co.jp>
	<1425952344.2579.20.camel@jtkirshe-mobl>
	<1425955695.2579.23.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1425955695.2579.23.camel@jtkirshe-mobl>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> On Mon, 2015-03-09 at 18:52 -0700, Jeff Kirsher wrote:
> > On Tue, 2015-03-10 at 01:42 +0000, Hiroshi Shimamoto wrote:
> > > > On 03/08/2015 02:15 PM, Or Gerlitz wrote:
> > > > > On Mon, Feb 23, 2015 at 11:14 PM, Jeff Kirsher
> > > > > <jeffrey.t.kirsher@intel.com> wrote:
> > > > > [...]
> > > > >> We discussed this during NetConf last week, and Don is correct
> > > that a
> > > > >> custom sysfs interface is not the way we want to handle this.  We
> > > agreed
> > > > >> upon a generic interface so that any NIC is able to turn on or
> > > off VF
> > > > >> multicast promiscuous mode.
> > > > >
> > > > > Jeff, please make sure to either respond to my comments on the V2
> > > > > thread (or better) address them for the V3 post.
> > > > >
> > > > >
> > > > > http://marc.info/?l=linux-netdev&m=142441852518152&w=2
> > > > > http://marc.info/?l=linux-netdev&m=142441867218183&w=2
> > > >
> > > > I agree with you that the patch descriptions should be cleaned up
> > > and
> > > > "beefed" up for that matter.
> > > >
> > > > If/when I look to push his series of patches, I will make sure that
> > > your
> > > > concerns are addressed so that we can get a accurate changelog.
> > >
> > > I see that the patchset should have better explanation in changelog.
> > > I will rewrite it and submit again.
> > >
> > > Jeff, are you planning to drop the patchset from your tree?
> > > I just concerned which tree I should create patches against for.
> >
> > Yes, I will drop the current patchset in my queue.  I am in the process
> > of updating my queue, go ahead and make your patches against the
> > following tree:
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> > all-queue branch
> >
> > If you give me an hour or so, I should have my tree updated with all the
> > patches in my queue currently.
> 
> Ok, correction on the branch name.  After doing some cleanup and future
> planning, the following tree:
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> is what you want to use and the branch name is:
> unstable-queue
> 
> The branch has all the patches currently in my queue.

OK, now I have the above branch:
>From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
   d7ed747..115403d  master     -> jeff-next/master
 * [new branch]      unstable-queue -> jeff-next/unstable-queue

I will work against that tree.

thanks,
Hiroshi
------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
