From: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
Date: Mon, 02 Mar 2015 17:23:04 +0100
Message-ID: <54F48E68.6070706@suse.cz>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz> <alpine.DEB.2.11.1503020944200.5540@gentwo.org> <54F48980.3090008@suse.cz> <alpine.DEB.2.11.1503021007030.6245@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.11.1503021007030.6245-gkYfJU5Cukgdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/02/2015 05:08 PM, Christoph Lameter wrote:
> On Mon, 2 Mar 2015, Vlastimil Babka wrote:
>
>>> You are thinking about an opportunistic allocation attempt in SLAB?
>>>
>>> AFAICT SLAB allocations should trigger reclaim.
>>>
>>
>> Well, let me quote your commit 952f3b51beb5:
>
> This was about global reclaim. Local reclaim is good and that can be
> done via zone_reclaim.

Right, so the patch is a functional change for zone_reclaim_mode == 1, 
where !__GFP_WAIT will prevent it.
