From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] sock_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 03:07:04 -0700 (PDT)
Message-ID: <20120627.030704.2277908466768005259.davem@davemloft.net>
References: <aebb990d61eec6d97f1dfe52a0579981c40cce9e.1340788373.git.tgraf@suug.ch>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F66@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab2F0KHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:07:12 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F66@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Wed, 27 Jun 2012 11:00:30 +0100

>  
>> @@ -35,9 +34,7 @@ EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
>>  
>>  int sock_diag_put_meminfo(struct sock *sk, struct sk_buff 
>> *skb, int attrtype)
>>  {
>> -	__u32 *mem;
>> -
>> -	mem = RTA_DATA(__RTA_PUT(skb, attrtype, SK_MEMINFO_VARS *
> sizeof(__u32)));
>> +	u32 mem[SK_MEMINFO_VARS];
> 
> Isn't that likely to blow the kernel stack?

8 * sizeof(u32)?  Surely not.
