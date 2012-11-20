From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 4/7] netprio_cgroup: reimplement priomap expansion
Date: Tue, 20 Nov 2012 16:16:50 +0100
Message-ID: <50AB9EE2.6000709@monom.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org> <1353400211-5182-5-git-send-email-tj@kernel.org> <50AB435E.8060901@monom.org> <20121120143832.GO15971@htj.dyndns.org> <50AB9D22.5030000@monom.org> <20121120151322.GR15971@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121120151322.GR15971-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20.11.2012 16:13, Tejun Heo wrote:
> Hello,
>
> On Tue, Nov 20, 2012 at 04:09:22PM +0100, Daniel Wagner wrote:
>> Thanks for the explanation. I was pondering if the new size in power
>> of two could be a bit too excessive and the allocation step could be
>> linear, e.g. stick at 4096. target_id will increase linear,
>> therefore linear increase might also be enough, no?
>
> Well, power-of-two resizing tends to behave relatively well under most
> cases and slab allocations are binned by power-of-two sizes, so
> linearly growing it doesn't really buy anything.

Convinced :)

Tested and Acked-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

thanks,
daniel
