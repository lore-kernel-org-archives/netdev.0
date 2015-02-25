From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision
 defined
Date: Tue, 24 Feb 2015 21:12:56 -0500 (EST)
Message-ID: <20150224.211256.2012225739825347238.davem@davemloft.net>
References: <54ECD57A.1080709@iogearbox.net>
	<20150224.163137.12835478467735127.davem@davemloft.net>
	<20150224224915.GB1199@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, johunt@akamai.com, pablo@netfilter.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150224224915.GB1199@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 24 Feb 2015 22:49:15 +0000

> On 02/24/15 at 04:31pm, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Let's fix as much crap as we can in -net.  I'm going to have to do
>> a huge backport of all the rhashtables to -stable at some point
>> too.
> 
> All fixes except 2-3 should only affect the post per bucket lock
> era. The fixes tags should be correct but I'll double check. I can
> take care of the backports if you like.

There were several bugs that are only cured by the "per bucket
lock era" version fo rhashtable.

I only applied all of that work to net-next at the time because
suspected we'd still have to hash all of that out.

Therefore, all of the rhashtable stuff that went into 4.0-rc1
is going to need to be backported.

I also really wish Herbert Xu didn't drop off the map on this work, we
could really use his expertiece and suggestions right now. :-/
