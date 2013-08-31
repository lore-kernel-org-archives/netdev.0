From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v11 01/11] ipv6: move ip6_dst_hoplimit() into
 core kernel
Date: Sat, 31 Aug 2013 01:56:04 -0400 (EDT)
Message-ID: <20130831.015604.1949690105050158177.davem@davemloft.net>
References: <1377918448-29888-2-git-send-email-amwang@redhat.com>
	<20130831.005925.168719024280186075.davem@davemloft.net>
	<1377925654.29366.1.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967Ab3HaF4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 01:56:14 -0400
In-Reply-To: <1377925654.29366.1.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 31 Aug 2013 13:07:34 +0800

> On Sat, 2013-08-31 at 00:59 -0400, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Sat, 31 Aug 2013 11:07:18 +0800
>> 
>> > @@ -75,3 +76,24 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
>> >  	return offset;
>> >  }
>> >  EXPORT_SYMBOL(ip6_find_1stfragopt);
>> > +
>> > +#if IS_ENABLED(CONFIG_IPV6)
>> > +int ip6_dst_hoplimit(struct dst_entry *dst)
>>  ...
>> > +#endif
>> > +EXPORT_SYMBOL(ip6_dst_hoplimit);
>> 
>> I don't think the export should be outside of the #if region.
>> 
>> Did you test the build with IPV6 disabled?
> 
> Yes, but it didn't show me any error.

Weird, please correct this anyways.

Thanks.
