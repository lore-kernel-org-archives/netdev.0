From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v9 1/9] Basic kernel memory functionality for the Memory
 Controller
Date: Fri, 16 Dec 2011 14:30:49 +0100
Message-ID: <20111216133049.GI3122@tiehlicka.suse.cz>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
 <1323676029-5890-2-git-send-email-glommer@parallels.com>
 <20111214170447.GB4856@tiehlicka.suse.cz>
 <4EE9E81E.2090700@parallels.com>
 <20111216123233.GF3122@tiehlicka.suse.cz>
 <4EEB417B.8000508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org, avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Weiner <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EEB417B.8000508-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri 16-12-11 17:02:51, Glauber Costa wrote:
> On 12/16/2011 04:32 PM, Michal Hocko wrote:
[...]
> >So why do we need kmem accounting when tcp (the only user at the moment)
> >doesn't use it?
> 
> Well, a bit historical. I needed a basic placeholder for it, since
> it tcp is officially kmem. As the time passed, I took most of the
> stuff out of this patch to leave just the basics I would need for
> tcp.
> Turns out I ended up focusing on the rest, and some of the stuff was
> left here.
> 
> At one point I merged tcp data into kmem, but then reverted this
> behavior. the kmem counter stayed.
> 
> I agree deferring the whole behavior would be better.
> 
> >>In summary, we still never do non-independent accounting. When we
> >>start doing it for the other caches, We will have to add a test at
> >>charge time as well.
> >
> >So we shouldn't do it as a part of this patchset because the further
> >usage is not clear and I think there will be some real issues with
> >user+kmem accounting (e.g. a proper memcg-oom implementation).
> >Can you just drop this patch?
> 
> Yes, but the whole set is in the net tree already. 

Isn't it only in some for-next branch? Can that one be updated?

> (All other patches are tcp-related but this) Would you mind if I'd
> send a follow up patch removing the kmem files, and leaving just the
> registration functions and basic documentation? (And sorry for that as
> well in advance)

Yes a followup patch would work as well.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
