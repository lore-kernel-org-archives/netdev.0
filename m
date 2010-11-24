From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Wed, 24 Nov 2010 09:14:49 -0800 (PST)
Message-ID: <20101124.091449.189711438.davem@davemloft.net>
References: <1290590335.3464.24.camel@edumazet-laptop>
	<877hg2g4re.fsf@basil.nowhere.org>
	<1290611906.3464.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, vegard.nossum@gmail.com,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	eugene@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290611906.3464.66.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Nov 2010 16:18:26 +0100

> 4) If we autotune a limit at boot time as a lowmem percentage, some guys
> then want a /proc/sys/net/core/max_unix_inflight sysctl , just for
> completeness. One extra sysctl... 
> 
> I cant see valid uses but programs designed to stress our stack.

I agree completely with Eric's analysis.

I would even consider setting this threshold lower. :-)

Anyways, consider Eric's patch applied.
