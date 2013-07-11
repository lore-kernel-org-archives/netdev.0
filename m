From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net RESEND v2] ipv6: fix route selection if kernel is
 not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 17:36:33 -0700 (PDT)
Message-ID: <20130710.173633.631366598766526289.davem@davemloft.net>
References: <20130710210012.GK15411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrus.lt@gmail.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421Ab3GKAg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:36:58 -0400
In-Reply-To: <20130710210012.GK15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 10 Jul 2013 23:00:12 +0200

> I changed the return value of rt6_check_neigh to:
>    1 in case of the dst entry validated
>   -1 in case of we had no dst_entry and we need to do rr now
>   -2 in case a we had a dst_entry and it did not validate

Please, at the very least, create an enumeration for this set of
possible return values.

Although I don't like how that RR boolean is passed around by
reference, I can't suggest anything better so I won't require
you to get rid of that.

Thanks.
