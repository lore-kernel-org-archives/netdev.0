From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Tue, 27 Oct 2015 20:05:19 -0700
Message-ID: <20151028030519.GA20789@cmpxchg.org>
References: <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151027.174532.469361008055673315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mhocko@kernel.org, akpm@linux-foundation.org,
	vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151027.174532.469361008055673315.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2015 at 05:45:32PM -0700, David Miller wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 27 Oct 2015 09:42:27 -0700
> 
> > On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> >> > For now, something like this as a boot commandline?
> >> > 
> >> > cgroup.memory=nosocket
> >> 
> >> That would work for me.
> > 
> > Okay, then I'll go that route for the socket stuff.
> > 
> > Dave is that cool with you?
> 
> Depends upon the default.
> 
> Until the user configures something explicitly into the memory
> controller, the networking bits should all evaluate to nothing.

Yep, I'll stick them behind a default-off jump label again.

This bootflag is only to override an active memory controller
configuration and force-off that jump label permanently.
