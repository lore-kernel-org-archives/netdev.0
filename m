From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v0 5/5] cgroup: Assign subsystem IDs during compile time
Date: Fri, 17 Aug 2012 15:25:19 +0800
Message-ID: <502DF1DF.8040109@huawei.com>
References: <1345126336-20755-1-git-send-email-wagi@monom.org> <1345126336-20755-6-git-send-email-wagi@monom.org> <20120816232010.GJ24861@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120816232010.GJ24861-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2012/8/17 7:20, Tejun Heo wrote:
> On Thu, Aug 16, 2012 at 04:12:16PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> We are able to safe some space when we assign the subsystem
>> IDs at compile time. Instead of allocating per cgroup
>> cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
>> always 64, we allocate 12 + 1 at max (at this point there are 12
>> subsystem).
> 
> So, IIUC, this is effectively removing the capability to implement
> modularized controller which isn't known at kernel compile time.  Am I
> right?
> 

I think so.

> I don't think that's a bad idea but if we're doing that, can't we make
> things even simpler?  Do we need to distinguish in-kernel and module
> at all?
> 
> Li, what do you think about this?
> 

I'm definitely all for simplicity, but I'm not sure if we can do better in
simplifying the code for modularized cgroup subsystem. (I guess you didn't
mean to remove this feature?)
