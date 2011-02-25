From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 11:05:29 -0800 (PST)
Message-ID: <20110225.110529.39178636.davem@davemloft.net>
References: <20110225151414.GA5211@albatros>
	<20110225.104720.71110261.davem@davemloft.net>
	<20110225190205.GA4541@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, xiaosuo@gmail.com, jesse@nicira.com,
	kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110225190205.GA4541@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Fri, 25 Feb 2011 22:02:05 +0300

> On Fri, Feb 25, 2011 at 10:47 -0800, David Miller wrote:
>> From: Vasiliy Kulikov <segoon@openwall.com>
>> Date: Fri, 25 Feb 2011 18:14:14 +0300
>> 
>> > Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
>> > CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
>> > that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are limited
>> > to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't allow
>> > anybody load any module not related to networking.
>> 
>> Why go through this naming change, which does break things, instead of
>> simply adding a capability mask tag or similar to modules somehow.  You
>> could stick it into a special elf section or similar.
>>
>> Doesn't that make tons more sense than this?
> 
> This is not "simply", adding special section for a single workaround
> seems like an overkill for me - this touches the core (modules'
> internals), which is not related to the initial CAP_* problem at all.
> 
> I'd be happy with not breaking anything, but I don't see any acceptable
> solution.

I think it's warranted given that it allows us to avoid breaking things.

I don't understand there is resistence in response to the first idea
I've seen proprosed that actually allows to fix the problem and not
break anything at the same time.

That seems silly.
