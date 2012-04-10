From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v2 2/2] cgroup: get rid of populate for memcg
Date: Tue, 10 Apr 2012 10:37:23 +0900
Message-ID: <4F838ED3.7050905@jp.fujitsu.com>
References: <1333728250-14248-1-git-send-email-glommer@parallels.com> <1333728250-14248-3-git-send-email-glommer@parallels.com> <20120409174042.GA7522@google.com> <4F83218E.7060502@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F83218E.7060502-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2012/04/10 2:51), Glauber Costa wrote:

> On 04/09/2012 02:40 PM, Tejun Heo wrote:
>> which BTW seems incorrect even on its
>> own - unmounting and mounting again would probably make the same
>> notifier registered multiple times corrupting notification chain, and
>> ref inc on the parent.
> 
> 
> For the maintainers: Should I fix those in a new submission, or do you 
> intend to do it yourselves?
> 
> the refcnt dropping should probably be done in my patch, it is a new 
> leak (sorry). The hotplug notifier, as tejun pointed, was already there.
> 
> It seems simple enough to fix, so if you guys want, I can bundle it in
> a new submission.
> 

Please make notifier fix patch against mm tree, as an independent one.

Thanks,
-Kame
