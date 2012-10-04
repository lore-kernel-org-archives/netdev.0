From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: release referenct of ip6_null_entry's dst entry
 in __ip6_del_rt
Date: Wed, 03 Oct 2012 23:02:47 -0400 (EDT)
Message-ID: <20121003.230247.1411266203908140826.davem@davemloft.net>
References: <20120921.131652.353726055575103840.davem@davemloft.net>
	<505FE24E.4030204@cn.fujitsu.com>
	<506CFA96.4050207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab2JDDCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 23:02:50 -0400
In-Reply-To: <506CFA96.4050207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 04 Oct 2012 10:55:18 +0800

> 于 2012年09月24日 12:32, Gao feng 写道:
>> 于 2012年09月22日 01:16, David Miller 写道:
>>> From: Gao feng <gaofeng@cn.fujitsu.com>
>>> Date: Thu, 20 Sep 2012 13:25:34 +0800
>>>
>>>> as we hold dst_entry before we call __ip6_del_rt,
>>>> so we should alse call dst_release not only return
>>>> -ENOENT when the rt6_info is ip6_null_entry.
>>>>
>>>> and we already hold the dst entry, so I think it's
>>>> safe to call dst_release out of the write-read lock.
>>>>
>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
 ...
> Can you apply this patch?

Sorry, I've been really busy this week.  I will try to get to
this soon.

Thanks.
