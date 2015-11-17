From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4/5] sock, cgroup: add sock->sk_cgroup
Date: Tue, 17 Nov 2015 16:25:54 -0500 (EST)
Message-ID: <20151117.162554.314531574043190960.davem@davemloft.net>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
	<1447789240-29394-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447789240-29394-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 17 Nov 2015 14:40:39 -0500

> In preparation, this patch adds sock->sk_cgroup which points to the
> associated cgroup.  A sock is associated on creation and stays
> associated to the same cgroup until freed; unfortunately, this ends up
> adding another cgroup field to struct sock on top of sk_cgrp_prioidx
> and sk_classid.  I tried to think of a way to somehow overload the
> existing fields but couldn't come up with a reasonable one.

sk->sk_cgrp_prioidx is simply sk->sk_cgroup->id, is it not?

We really need to consolidate this before we stuff even more members
into the socket for control group support, sorry.
