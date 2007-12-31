From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Mon, 31 Dec 2007 13:58:43 -0500
Message-ID: <47793BE3.6000704@redhat.com>
References: <47775D8C.5010104@redhat.com>	<47775E7A.60708@redhat.com> <20071231.001925.151533664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591AbXLaS7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 13:59:30 -0500
In-Reply-To: <20071231.001925.151533664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Sun, 30 Dec 2007 04:01:46 -0500
> 
>> diff -pruN net-2.6.25-t12t19m-p4/net/ipv4/proc.c net-2.6.25-t12t19m-p5/net/ipv4/proc.c
>> --- net-2.6.25-t12t19m-p4/net/ipv4/proc.c	2007-12-27 10:19:02.000000000 -0500
>> +++ net-2.6.25-t12t19m-p5/net/ipv4/proc.c	2007-12-29 21:09:21.000000000 -0500
>> @@ -56,7 +56,8 @@ static int sockstat_seq_show(struct seq_
>>  		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
>>  		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
>>  		   atomic_read(&tcp_memory_allocated));
>> -	seq_printf(seq, "UDP: inuse %d\n", sock_prot_inuse(&udp_prot));
>> +	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse(&udp_prot),
>> +		   atomic_read(&udp_memory_allocated));
>>  	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_prot));
>>  	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
>>  	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
> 
> More careless patch creation.  :-/
> 
> This breaks the build because udp_memory_allocated is not added until
> patch 2.

Hello David,

You are absolutely right.

> Once again I'll combine all three patches into one but I am extremely
> angry about how careless and broken these two patch submissions were.

I really apologize for wasting your time twice.
I do not do this kind mess again.

Many thanks for your support.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
