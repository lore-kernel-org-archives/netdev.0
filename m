From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Tue, 27 Oct 2015 17:45:32 -0700 (PDT)
Message-ID: <20151027.174532.469361008055673315.davem@davemloft.net>
References: <20151027154138.GA4665@cmpxchg.org>
	<20151027161554.GJ9891@dhcp22.suse.cz>
	<20151027164227.GB7749@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151027164227.GB7749-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Date: Tue, 27 Oct 2015 09:42:27 -0700

> On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
>> > For now, something like this as a boot commandline?
>> > 
>> > cgroup.memory=nosocket
>> 
>> That would work for me.
> 
> Okay, then I'll go that route for the socket stuff.
> 
> Dave is that cool with you?

Depends upon the default.

Until the user configures something explicitly into the memory
controller, the networking bits should all evaluate to nothing.
