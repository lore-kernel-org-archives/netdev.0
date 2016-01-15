From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: preserve IP control block during GSO
 segmentation
Date: Fri, 15 Jan 2016 14:35:53 -0500 (EST)
Message-ID: <20160115.143553.1070533798353652921.davem@davemloft.net>
References: <145225570625.30903.13936642758071448458.stgit@zurg>
	<20160113.155112.119405358547782630.davem@davemloft.net>
	<20160113233628.GA10507@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: koct9i@gmail.com, netdev@vger.kernel.org, dev@openvswitch.org,
	cascardo@redhat.com, edumazet@google.com,
	linux-kernel@vger.kernel.org, pshelar@nicira.com,
	xiyou.wangcong@gmail.com
To: fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113233628.GA10507@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Thu, 14 Jan 2016 00:36:28 +0100

> David Miller <davem@davemloft.net> wrote:
>> From: Konstantin Khlebnikov <koct9i@gmail.com>
>> Date: Fri, 08 Jan 2016 15:21:46 +0300
>> 
>> > Skb_gso_segment() uses skb control block during segmentation.
>> > This patch adds 32-bytes room for previous control block which
>> > will be copied into all resulting segments.
>> > 
>> > This patch fixes kernel crash during fragmenting forwarded packets.
>> > Fragmentation requires valid IP CB in skb for clearing ip options.
>> > Also patch removes custom save/restore in ovs code, now it's redundant.
>> > 
>> > Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>> > Link: http://lkml.kernel.org/r/CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com
>> 
>> If this works I definitely prefer this approach to the other patch
>> where the CB is copied back and forth.
> 
> I quite frankly don't care and just like you to apply one or the other;
> use coin toss if needed :-}

So I am going to apply this patch from Konstantin and queued it up for -stable.

Thanks.
