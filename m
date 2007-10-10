From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 2/4] UDP memory usage accounting (take 4): accounting
 unit and variable
Date: Wed, 10 Oct 2007 17:14:12 +0900
Message-ID: <470C89D4.8080409@hitachi.com>
References: <47065139.5030402@hitachi.com> <470651B3.6060001@hitachi.com> <20071007100938.GA24475@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, ?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:33055 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbXJJIOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 04:14:18 -0400
Received: from mlsv9.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 6DDEA33CD8
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 17:14:17 +0900 (JST)
In-Reply-To: <20071007100938.GA24475@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Thank you for your comment.

> Hi.
> 
> On Sat, Oct 06, 2007 at 12:01:07AM +0900, Satoshi OSHIMA (satoshi.oshima.fk@hitachi.com) wrote:
>> --- 2.6.23-rc3-udp_limit.orig/net/ipv4/udp.c
>> +++ 2.6.23-rc3-udp_limit/net/ipv4/udp.c
>> @@ -113,6 +113,10 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
>>  struct hlist_head udp_hash[UDP_HTABLE_SIZE];
>>  DEFINE_RWLOCK(udp_hash_lock);
>>  
>> +atomic_t udp_memory_allocated;
>> +
>> +EXPORT_SYMBOL(udp_memory_allocated);
>> +
> 
> Why do you export this variable?
> It is not accessed from modules in your patchset.

Good point! I'll fix it.

Satoshi Oshima
