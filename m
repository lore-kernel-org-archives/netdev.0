From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Fri, 23 Oct 2015 06:59:57 -0700 (PDT)
Message-ID: <20151023.065957.1690815054807881760.davem@davemloft.net>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
	<1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
	<20151023131956.GA15375@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151023131956.GA15375-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Fri, 23 Oct 2015 15:19:56 +0200

> On Thu 22-10-15 00:21:33, Johannes Weiner wrote:
>> Socket memory can be a significant share of overall memory consumed by
>> common workloads. In order to provide reasonable resource isolation
>> out-of-the-box in the unified hierarchy, this type of memory needs to
>> be accounted and tracked per default in the memory controller.
> 
> What about users who do not want to pay an additional overhead for the
> accounting? How can they disable it?

Yeah, this really cannot pass.

This extra overhead will be seen by %99.9999 of users, since entities
(especially distributions) just flip on all of these config options by
default.
