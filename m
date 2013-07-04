From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until
 next-hop is in neighbor cache
Date: Wed, 03 Jul 2013 17:51:53 -0700 (PDT)
Message-ID: <20130703.175153.1664868495830722209.davem@davemloft.net>
References: <20130703181546.GC12615@order.stressinduktion.org>
	<51D46B9F.6050400@cogentembedded.com>
	<20130703184504.GD12615@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, petrus.lt@gmail.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3GDAvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 20:51:54 -0400
In-Reply-To: <20130703184504.GD12615@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 3 Jul 2013 20:45:04 +0200

> On Wed, Jul 03, 2013 at 10:21:19PM +0400, Sergei Shtylyov wrote:
>>    How about:
>> 
>> 	} else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
>> 
>> >+		ret = true;
>> >+#endif
>> >  	}
> 
> Definitely an improvment, thanks!
> 
> [PATCH net v2] ipv6: rt6_check_neigh should successfully verify neigh if no NUD information are available

Applied and queued up for -stable, thanks everyone.
