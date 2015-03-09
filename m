From: David Miller <davem@redhat.com>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 09 Mar 2015 15:20:24 -0400 (EDT)
Message-ID: <20150309.152024.1504931799646487883.davem@redhat.com>
References: <20150309131356.GB28039@breakpoint.cc>
	<20150309.131613.2015932954920552655.davem@redhat.com>
	<20150309173515.GB30297@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150309173515.GB30297@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Mon, 9 Mar 2015 18:35:15 +0100

> David Miller <davem@redhat.com> wrote:
>> > The 2nd (and last half) of the set folds nf_bridge_info into skbuff,
>> > at the end (where its not initialized at allocation time).
>> > 
>> > The struct is a lot smaller by then (16 bytes on 64bit, 12 on 32bit)
>> > so we'd increase skbuff size only by 8.
>> 
>> Sorry, increases in size of any kind of sk_buff are strongly discouraged.
> 
> No need to be sorry, its not a show-stopper.
> Its the last patch in the series and nothing depends on this change.
> 
>> Especially for something like nfbridge.
> 
> Its not initialized, ever, if bridge is not used, so it shouldn't be a big
> deal.

It's about the overall size of the structure, not whether the member is
ever used or not.
