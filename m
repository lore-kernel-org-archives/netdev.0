From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 10:40:13 -0500
Message-ID: <20151123154013.GB3049@mtj.duckdns.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-10-git-send-email-tj@kernel.org>
 <20151121165605.GC25336@breakpoint.cc>
 <20151121170425.GD3428@htj.duckdns.org>
 <20151121185419.GD25336@breakpoint.cc>
 <565317F0.2030502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <565317F0.2030502-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Daniel.

On Mon, Nov 23, 2015 at 02:43:12PM +0100, Daniel Borkmann wrote:
...
> Haven't looked deeply into kernfs, but if it's possible to get the object
> from the struct file eventually, you could let iptables frontend open that
> path and just pass the fd down. Would be sizeof(int) vs PATH_MAX then, i.e.
> when you have a large number of rules to load.

That works in one direction but not in the other.  ie. You can tell
the kernel the path that way but can't retrieve.  If using path string
is unacceptable, the best alternative would be an inode number rather
than a fd; however, using an inode number would be quite cumbersome
and painful too.

Thanks.

-- 
tejun
