From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/7] kernfs: implement kernfs_walk_and_get()
Date: Fri, 20 Nov 2015 13:41:55 -0800
Message-ID: <20151120214155.GB21590@kroah.com>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <1447959171-20749-3-git-send-email-tj@kernel.org>
 <20151120044104.GA10693@kroah.com>
 <20151120211254.GE1574@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151120211254.GE1574-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2015 at 04:12:54PM -0500, Tejun Heo wrote:
> On Thu, Nov 19, 2015 at 08:41:04PM -0800, Greg Kroah-Hartman wrote:
> > On Thu, Nov 19, 2015 at 01:52:46PM -0500, Tejun Heo wrote:
> > > Implement kernfs_walk_and_get() which is similar to
> > > kernfs_find_and_get() but can walk a path instead of just a name.
> > > 
> > > v2: Use strlcpy() instead of strlen() + memcpy() as suggested by
> > >     David.
> > > 
> > > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > > Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> > > Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > ---
> > >  fs/kernfs/dir.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
> > >  include/linux/kernfs.h | 12 ++++++++++++
> > >  2 files changed, 58 insertions(+)
> > 
> > Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> 
> Greg, would it be okay to route this one through either cgroup or net
> tree?

Either is fine with me, whatever works best for you.

greg k-h
