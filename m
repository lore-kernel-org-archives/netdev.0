From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Wed, 16 May 2012 17:28:29 +0900
Message-ID: <4FB3652D.2040909@jp.fujitsu.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com> <4FB3431C.3050402@parallels.com> <4FB3518B.3090205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB3518B.3090205-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2012/05/16 16:04), Glauber Costa wrote:

> On 05/16/2012 10:03 AM, Glauber Costa wrote:
>>> BTW, what is the relationship between 1/2 and 2/2  ?
>> Can't do jump label patching inside an interrupt handler. They need to
>> happen when we free the structure, and I was about to add a worker
>> myself when I found out we already have one: just we don't always use it.
>>
>> Before we merge it, let me just make sure the issue with config Li
>> pointed out don't exist. I did test it, but since I've reposted this
>> many times with multiple tiny changes - the type that will usually get
>> us killed, I'd be more comfortable with an extra round of testing if
>> someone spotted a possibility.
>>
>> Who is merging this fix, btw ?
>> I find it to be entirely memcg related, even though it touches a file in
>> net (but a file with only memcg code in it)
>>
> 
> For the record, I compiled test it many times, and the problem that Li
> wondered about seems not to exist.
> 

Ah...Hmm.....I guess dependency problem will be found in -mm if any rather than
netdev...

David, can this bug-fix patch goes via -mm tree ? Or will you pick up ?

CC'ed David Miller and Andrew Morton.

Thanks,
-Kame
