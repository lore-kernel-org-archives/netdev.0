From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCHSET v2] netfilter, cgroup: implement xt_cgroup2 match
Date: Fri, 20 Nov 2015 20:57:39 +0100
Message-ID: <20151120195739.GA1251@salvia>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <20151120.135912.1506496112678349111.davem@davemloft.net>
 <20151120195625.GA1124@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151120195625.GA1124@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2015 at 08:56:25PM +0100, Pablo Neira Ayuso wrote:
> Regarding #7, I have a couple two concerns:
> 
> 1) cgroup currently doesn't work the way users expect, ie. to perform any
>    reasonable firewalling. Since this relies on early demux, only a
>    limited number of sockets get access to the cgroup info.

Ops sorry, I forgot to indicate that I'm refering to the INPUT chain.

> 2) We have traditionally rejected match2 and target2 extensions. I
>    guess you can accomodate the new cgroup code through the revision
>    iptables infrastructure, so we still use the cgroup match.
> 
> Let me know, thanks.
