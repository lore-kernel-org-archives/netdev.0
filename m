From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/8] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 12:36:48 -0500
Message-ID: <87zj7j8mhb.fsf@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	<87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
	<1426093813.11398.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com, Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42715 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbCKRk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:40:29 -0400
In-Reply-To: <1426093813.11398.52.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 11 Mar 2015 10:10:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2015-03-11 at 11:35 -0500, Eric W. Biederman wrote:
>
>> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
>> index 6d592f8555fb..e0d5c8327159 100644
>> --- a/net/ipv4/inet_timewait_sock.c
>> +++ b/net/ipv4/inet_timewait_sock.c
>> @@ -98,7 +98,7 @@ void inet_twsk_free(struct inet_timewait_sock *tw)
>>  #ifdef SOCK_REFCNT_DEBUG
>>  	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
>>  #endif
>> -	release_net(twsk_net(tw));
>> +	twsk_net(tw);
>>  	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
>>  	module_put(owner);
>>  }
>
>
> Not clear why you left this line ?

I goofed and then I overlooked the goof.

Eric
