From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Thu, 29 Oct 2015 09:10:09 -0700
Message-ID: <20151029161009.GA9160@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151029152546.GG23598-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2015 at 04:25:46PM +0100, Michal Hocko wrote:
> On Tue 27-10-15 09:42:27, Johannes Weiner wrote:
> > On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> > > On Tue 27-10-15 11:41:38, Johannes Weiner wrote:
> > > > IMO that's an implementation detail and a historical artifact that
> > > > should not be exposed to the user. And that's the thing I hate about
> > > > the current opt-out knob.
> > 
> > You carefully skipped over this part. We can ignore it for socket
> > memory but it's something we need to figure out when it comes to slab
> > accounting and tracking.
> 
> I am sorry, I didn't mean to skip this part, I though it would be clear
> from the previous text. I think kmem accounting falls into the same
> category. Have a sane default and a global boottime knob to override it
> for those that think differently - for whatever reason they might have.

Yes, that makes sense to me.

Like cgroup.memory=nosocket, would you think it makes sense to include
slab in the default for functional/semantical completeness and provide
a cgroup.memory=noslab for powerusers?
