From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: recursive check rt->dst.from when call
 rt6_check_expired
Date: Wed, 19 Sep 2012 13:41:39 -0400 (EDT)
Message-ID: <20120919.134139.249773796773112801.davem@davemloft.net>
References: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
	<505980BE.5060300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab2ISRll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:41:41 -0400
In-Reply-To: <505980BE.5060300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Wed, 19 Sep 2012 16:22:22 +0800

> 于 2012年09月14日 13:54, roy.qing.li@gmail.com 写道:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> If dst cache dst_a copies from dst_b, and dst_b copies from dst_c, check
>> if dst_a is expired or not, we should not end with dst_a->dst.from, dst_b,
>> we should check dst_c.
>> 
>> CC: Gao feng <gaofeng@cn.fujitsu.com>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
> 
> Looks good to me,thanks rongqing :)

An explicit "Acked-by: " is more useful to us than simply saying
it looks good.
