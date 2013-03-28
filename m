From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] net-next: replace obsolete NLMSG_* with type safe
 nlmsg_*
Date: Thu, 28 Mar 2013 14:00:57 -0400 (EDT)
Message-ID: <20130328.140057.1029413611130335133.davem@davemloft.net>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
	<20130328143216.GC23043@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130328143216.GC23043@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Mar 2013 14:32:16 +0000

> On 03/28/13 at 12:47am, Hong Zhiguo wrote:
>> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
>> index 505b30a..467fb92 100644
>> --- a/net/ipv4/udp_diag.c
>> +++ b/net/ipv4/udp_diag.c
>> @@ -64,9 +64,9 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>>  		goto out;
>>  
>>  	err = -ENOMEM;
>> -	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
>> -				     sizeof(struct inet_diag_meminfo) +
>> -				     64)), GFP_KERNEL);
>> +	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
>> +				     sizeof(struct inet_diag_meminfo) + 64,
>> +				     GFP_KERNEL);
> 
> This is formatted incorrectly, otherwise the patch looks good.

I'll fix it up when I commit.
