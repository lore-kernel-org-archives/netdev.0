From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v3 6/6] cgroup: Assign subsystem IDs during compile time
Date: Tue, 14 Aug 2012 23:01:28 +0200
Message-ID: <502ABCA8.1000008@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org> <1344949343-26090-8-git-send-email-wagi@monom.org> <20120814172749.GL25632@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120814172749.GL25632-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 08/14/2012 07:27 PM, Tejun Heo wrote:
> On Tue, Aug 14, 2012 at 03:02:23PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> We are able to safe some space when we assign the subsystem
>> IDs at compile time. Instead of allocating per cgroup
>> cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
>> always 64, we allocate 12 + 1 at max (at this point there are 12
>> subsystem). The additinal one is the price we have to pay to
>> distinguish between builtin and module subsystems.
>>
>> We should only access task_cls_classid() and task_netprioidx()
>> if the subsystem is ready to be used using jump labels for this.
>
> I think I want to like this patch but it's kinda confusing to review.
> Is there any reasonable way that you can split the core changes from
> net_cls ones?

My bad, sorry about that. Sure, I'll split the patches into smaller 
pieces and remove net_cls updating part as Neil has requested. You will 
get someting to review on Thursday, since tomorrow I am out of office.

thanks,
daniel
