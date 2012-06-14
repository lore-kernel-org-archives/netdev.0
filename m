From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid
	cache misses
Date: Thu, 14 Jun 2012 15:30:07 -0700
Message-ID: <20120614223007.GD8006@kroah.com>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
	<4FD11F49.5060805@gmail.com>
	<20120607.144358.1732928576389957779.davem@davemloft.net>
	<20120608021542.GA10112@kroah.com>
	<1339141042.7850.51.camel@rkaganb.sw.ru>
	<1339585937.17472.11.camel@rkaganb.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"dnelson@redhat.com" <dnelson@redhat.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Roman Kagan <rkagan@parallels.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1339585937.17472.11.camel@rkaganb.sw.ru>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2012 at 03:12:17PM +0400, Roman Kagan wrote:
> On Fri, 2012-06-08 at 11:37 +0400, Roman Kagan wrote:
> > On Fri, 2012-06-08 at 06:15 +0400, Greg KH wrote:
> > > On Thu, Jun 07, 2012 at 02:43:58PM -0700, David Miller wrote:
> > > > From: Jeff Kirsher <tarbal@gmail.com>
> > > > Date: Thu, 07 Jun 2012 14:38:17 -0700
> > > > 
> > > > > Thanks! I have applied the patch to my queue
> > > > 
> > > > Why?
> > > > 
> > > > My impression is that this is a patch already in the tree, and it's
> > > > being submitted for -stable but such minor performance hacks are
> > > > absolutely not appropriate for -stable submission.
> > > 
> > > The patch description says it is fixing reported oopses,
> > 
> > Exactly.
> > 
> > > but the Subject: isn't all that helpful there.
> > 
> > Well I just preserved the original subject from the upstream commit.
> > Want me to resubmit with a more alarming one?
> > 
> > > So which is this?  Should I accept it for a stable release or not?
> > 
> > IMO yes ;)
> 
> What came out of this discussion?  Should I resubmit with a different
> subject, or the original one is good enough?
> 
> The patch resolves a real oops; we've seen it multiple times when
> running Ubuntu-11.10 in virtual machines.  Upstream and RHEL have the
> fix since long.  Ubuntu is waiting for 3.0-stable to merge it
> (https://bugs.launchpad.net/bugs/1009545).

That's pretty funny that Ubuntu is letting me be the gatekeeper of fixes
to get to their customers, there's just so much wrong in that it's sad.

Anyway, I've queued it up for the next 3.0-stable release.

thanks,

greg k-h

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
