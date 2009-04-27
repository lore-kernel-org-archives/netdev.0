From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 00:36:16 +0400
Message-ID: <20090427203616.GB3836@ioremap.net>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu> <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, Apr 27, 2009 at 12:46:48PM -0700, Linus Torvalds (torvalds@linux-foundation.org) wrote:
> > All those references support my argument that the lock is being
> > used recursively in this case.
> 
> What's so hard between understanding the difference between "used 
> recursively" and "recursive lock"?
> 
> THEY MEAN TWO TOTALLY DIFFERENT THINGS!
> 
> The fact that you don't seem to understand that is one of the things I've 
> been complaining about all along.

Just ot be sure readers will not lose the discssion topic: do you object
against naming or realizaion? If its about the former, does 'dog's
breath lock' proposed by Stephen fit?

-- 
	Evgeniy Polyakov
