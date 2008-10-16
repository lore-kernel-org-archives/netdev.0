From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/7] netns ebtables: part 1
Date: Thu, 16 Oct 2008 23:39:55 +0400
Message-ID: <20081016193955.GA26245@x200.localdomain>
References: <20081015042014.GE24058@x200.localdomain> <48F73DA3.1030401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48F73DA3.1030401@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2008 at 03:12:03PM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> One needs to add ".netns_ok = 1" to igmp_protocol to test all of this
>> with ebtables() in netns.
>> -------------------------------------------------
>> [PATCH 1/7] netns ebtables: part 1
>>
>> * make list of ebt_tables per-netns
>> * propagate netns from userspace, register table in passed netns
>> * temporarily register every ebt_table in init_net
>
> I'm not queuing patches for 2.6.29 yet, please resend the entire
> batch once Dave opens his net-next tree again.
>
>> --- a/include/net/netns/x_tables.h
>> +++ b/include/net/netns/x_tables.h
>> @@ -6,5 +6,6 @@
>>   struct netns_xt {
>>  	struct list_head tables[NPROTO];
>> +	struct list_head ebt_tables;
>
> This could just use tables[NFPROTO_BRIDGE].

Good!

[drops some code]

I do wonder why these new numbers a) contain holes and b) exported in
headers.
