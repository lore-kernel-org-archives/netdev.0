From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] cgroup: bpf: Add
 BPF_MAP_TYPE_CGROUP_ARRAY
Date: Thu, 23 Jun 2016 17:13:26 -0400
Message-ID: <20160623211326.GK3262@mtj.duckdns.org>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com>
 <1466630252-3822277-3-git-send-email-kafai@fb.com>
 <576BAF07.4020302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <576BAF07.4020302-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Jun 23, 2016 at 11:42:31AM +0200, Daniel Borkmann wrote:
> I presume it's a valid use case to pin a cgroup map, put fds into it and
> remove the pinned file expecting to continue to match on it, right? So
> lifetime is really until last prog using a cgroup map somewhere gets removed
> (even if not accessible from user space anymore, meaning no prog has fd and
> pinned file was removed).

Yeap, from what I can see, the cgroup will stay around (even if it
gets deleted) as long as the bpf rule using it is around and that's
completely fine from cgroup side.

Thanks.

-- 
tejun
