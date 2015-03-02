From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
Date: Mon, 2 Mar 2015 10:08:19 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1503021007030.6245@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz> <alpine.DEB.2.11.1503020944200.5540@gentwo.org> <54F48980.3090008@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Rientjes <rientjes@google.com>,
    Andrew Morton <akpm@linux-foundation.org>,
    Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
    Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>,
    Pravin Shelar <pshelar@nicira.com>,
    Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>,
    Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org,
    dev@openvswitch.org
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <54F48980.3090008@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Mar 2015, Vlastimil Babka wrote:

> > You are thinking about an opportunistic allocation attempt in SLAB?
> >
> > AFAICT SLAB allocations should trigger reclaim.
> >
>
> Well, let me quote your commit 952f3b51beb5:

This was about global reclaim. Local reclaim is good and that can be
done via zone_reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
