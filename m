From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v0 0/5] cgroup: Assign subsystem IDs during compile time
Date: Thu, 16 Aug 2012 15:37:52 -0700
Message-ID: <502D7640.1000703@intel.com>
References: <1345126336-20755-1-git-send-email-wagi@monom.org> <20120816190542.GA8203@hmsreliant.think-freely.org> <502D5737.1010604@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <502D5737.1010604-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8/16/2012 1:25 PM, Daniel Wagner wrote:
> Hi Neil,
>
> On 08/16/2012 09:05 PM, Neil Horman wrote:
>>> Daniel Wagner (5):
>>>     cgroup: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
>>>     cgroup: Move sock_update_classid() decleration to cls_cgroup.h
>>>     cgroup: Protect access to task_cls_classid() when built as module
>>>     cgroup: Protect access to task_netprioidx() when built as module
>>>     cgroup: Assign subsystem IDs during compile time
>>
>> The series seems reasonable.  I presume you've testing building and running both
>> net_prio and net_cls as modules and monolithically?
>> Neil
>
> Yep, I spend a good bit of time rebuilding and testing all patches in
> the different configuration. I hope I really got the small semantic
> differences between net_cls and net_prio regarding the loading and
> unloading correct. So please have a close look at the jump label
> patches (#3 and #4).
>
> BTW, I have a few mores on top of these patches, e.g. merging the
> builtin and module version of task_cls_classid()/task_netprioidx()
> implementation together and getting rid of the many ifdefs in the
> header. But let's first get this part reviewed.
>
> thanks,
> daniel
>

Also I have another series for netprio against net-next to clean up
some of the locking as suggested by Al Viro. I'll wait to submit those
until after this series has been reviewed/applied.

In the meantime I'll apply these to my local tree and test these.
