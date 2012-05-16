From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Wed, 16 May 2012 12:30:25 +0400
Message-ID: <4FB365A1.6040101@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com> <4FB3431C.3050402@parallels.com> <4FB3518B.3090205@parallels.com> <4FB3652D.2040909@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB3652D.2040909-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/16/2012 12:28 PM, KAMEZAWA Hiroyuki wrote:
>> For the record, I compiled test it many times, and the problem that Li
>> >  wondered about seems not to exist.
>> >  
> Ah...Hmm.....I guess dependency problem will be found in -mm if any rather than
> netdev...

Yes. As I said, this only touches stuff in core memcg and the memcg
specific file. Any conflicts should come from other memcg fixes that may
have got into the tree...
> David, can this bug-fix patch goes via -mm tree ? Or will you pick up ?
> 
> CC'ed David Miller and Andrew Morton.
> 
> Thanks,
> -Kame
> 
> 
