From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v8 0/9] per-cgroup tcp memory pressure controls
Date: Wed, 7 Dec 2011 09:06:17 -0200
Message-ID: <4EDF48A9.6090306@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>,
	<avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323120903-2831-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/05/2011 07:34 PM, Glauber Costa wrote:
> Hi,
>
> This is my new attempt to fix all the concerns that were raised during
> the last iteration.
>
> I should highlight:
> 1) proc information is kept intact. (although I kept the wrapper functions)
>     it will be submitted as a follow up patch so it can get the attention it
>     deserves
> 2) sockets now hold a reference to memcg. sockets can be alive even after the
>     task is gone, so we don't bother with between cgroups movements.
>     To be able to release resources more easily in this cenario, the parent
>     pointer in struct cg_proto was replaced by a memcg object. We then iterate
>     through its pointer (which is cleaner anyway)
>
> The rest should be mostly the same except for small fixes and style changes.
>

Kame,

Does this one address your previous concerns?

Thanks
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
