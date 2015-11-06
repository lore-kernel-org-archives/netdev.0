From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Fri, 6 Nov 2015 12:45:17 -0500
Message-ID: <20151106174517.GA9315@cmpxchg.org>
References: <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151105225200.GA5432@cmpxchg.org>
 <20151106105724.GG4390@dhcp22.suse.cz>
 <20151106161953.GA7813@cmpxchg.org>
 <20151106164657.GL4390@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151106164657.GL4390-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 05:46:57PM +0100, Michal Hocko wrote:
> The basic problem was that the Delegate feature has been backported to
> our systemd package without further consideration and that has
> invalidated a lot of performance testing because some resource
> controllers have measurable effects on those benchmarks.

You're talking about a userspace bug. No amount of fragmenting and
layering and opt-in in the kernel's runtime configuration space is
going to help you if you screw up and enable it all by accident.

> > All I read here is vague inflammatory language to spread FUD.
> 
> I was merely pointing out that memory controller might be enabled without
> _user_ actually even noticing because the controller wasn't enabled
> explicitly. I haven't blamed anybody for that.

Why does that have anything to do with how we design our interface?

We can't do more than present a sane interface in good faith and lobby
userspace projects if we think they misuse it.
