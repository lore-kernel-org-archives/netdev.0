From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHSET v2] netfilter, cgroup: implement xt_cgroup2 match
Date: Fri, 20 Nov 2015 13:59:12 -0500 (EST)
Message-ID: <20151120.135912.1506496112678349111.davem@davemloft.net>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
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
In-Reply-To: <1447959171-20749-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 19 Nov 2015 13:52:44 -0500

> This is the second take of the xt_cgroup2 patchset.  Changes from the
> last take are
> 
> * Instead of adding sock->sk_cgroup separately, sock->sk_cgrp_data now
>   carries either (prioidx, classid) pair or cgroup2 pointer.  This
>   avoids inflating struct sock with yet another cgroup related field.
>   Unfortunately, this does add some complexity but that's the
>   trade-off and the complexity is contained in cgroup proper.
> 
> * Various small updats as per David and Jan's reviews.

I like this a lot better, thanks.

Please address Daniel's feedback on patch #6 and then I'm personally
fine with this series.

Pablo, are you ok with me merging this into net-next directly or
would you rather I take patches 1-6 into net-next and then you can
merge and then add patch #7 on top?

Thanks.
