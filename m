From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Tue, 27 Oct 2015 06:49:16 -0700 (PDT)
Message-ID: <20151027.064916.312540587298733586.davem@davemloft.net>
References: <20151023.065957.1690815054807881760.davem@davemloft.net>
	<20151026165619.GB2214@cmpxchg.org>
	<20151027122647.GG9891@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151027122647.GG9891-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 27 Oct 2015 13:26:47 +0100

> On Mon 26-10-15 12:56:19, Johannes Weiner wrote:
> [...]
>> Or any other combination of pick-and-choose consumers. But
>> honestly, nowadays all our paths are lockless, and the counting is an
>> atomic-add-return with a per-cpu batch cache.
> 
> You are still hooking into hot paths and there are users who want to
> squeeze every single cycle from the HW.

Yeah, you're basically probably undoing a half year of work by another
developer who was able to remove an atomic from these paths.
