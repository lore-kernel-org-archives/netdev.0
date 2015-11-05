From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Thu, 5 Nov 2015 17:28:03 +0100
Message-ID: <20151105162803.GD15111@dhcp22.suse.cz>
References: <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105.111609.1695015438589063316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151105.111609.1695015438589063316.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu 05-11-15 11:16:09, David S. Miller wrote:
> From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Thu, 5 Nov 2015 15:40:02 +0100
> 
> > On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
> > [...]
> >> Because it goes without saying that once the cgroupv2 interface is
> >> released, and people use it in production, there is no way we can then
> >> *add* dentry cache, inode cache, and others to memory.current. That
> >> would be an unacceptable change in interface behavior.
> > 
> > They would still have to _enable_ the config option _explicitly_. make
> > oldconfig wouldn't change it silently for them. I do not think
> > it is an unacceptable change of behavior if the config is changed
> > explicitly.
> 
> Every user is going to get this config option when they update their
> distibution kernel or whatever.
> 
> Then they will all wonder why their networking performance went down.
> 
> This is why I do not want the networking accounting bits on by default
> even if the kconfig option is enabled.  They must be off by default
> and guarded by a static branch so the cost is exactly zero.

Yes, that part is clear and Johannes made it clear that the kmem tcp
part is disabled by default. Or are you considering also all the slab
usage by the networking code as well?

-- 
Michal Hocko
SUSE Labs
