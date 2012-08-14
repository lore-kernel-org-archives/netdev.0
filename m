From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v3 0/6]  cgroup cls & netprio 'cleanups'
Date: Tue, 14 Aug 2012 15:25:50 +0200
Message-ID: <502A51DE.7040809@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org> <20120814131035.GC18731@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120814131035.GC18731-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Neil,

On 14.08.2012 15:10, Neil Horman wrote:
> On Tue, Aug 14, 2012 at 03:02:16PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> Hi,
>>
>> Sorry for the delay on updating this series. The usual
>> excuse apply here.
>>
>> I saw that John is busy improving net_prio so I took the
>> liberty to port his changes to net_cls (#1-3). Patch #3 will
>> collide with John's unapplied patches. I am happy
>> to rebase this series if needed.
>>
>> Patch #4 and #5 improve the readability with using
>> IS_MODULE/BUILTIN macros. This patches prepare the last
>> patch.
>>
>> Patch #6 removes support for assigning subsystem IDs during
>> runtime. As it turns out this is not really needed. By doing
>> so we are able to free some unused memory.
>>
>> The patches are against net-next.
>>
>> cheers,
>> daniel
>>
> These aren't so much 'cleanups' as feature enhancements and fixes for the first
> pass of those enhancements (at least in the case of the net_prio cgroup).

Sorry about that. I wanted to keep the series title, so that someone 
looking up older versions find it.

> I've nothing against them, but since we're still going through some churn on the
> net_prio variant, it may be best to wait until thats settled before moving them
> over to net_cls.

Sure, I can update this series when the net_prio controller changes have 
settled down.

I just wonder if it wouldn't make sense to merge them together. 
Obviously, that will break the user space which is not a good thing but 
having a controller per socket option is not good either.

cheers,
daniel
