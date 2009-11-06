From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] mac80211: Speedup
 ieee80211_remove_interfaces()
Date: Fri, 06 Nov 2009 00:44:41 -0800 (PST)
Message-ID: <20091106.004441.73060450.davem@davemloft.net>
References: <4AF2A3B0.4030100@gmail.com>
	<1257446408.29454.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linville@tuxdriver.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755230AbZKFIoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:44:15 -0500
In-Reply-To: <1257446408.29454.4.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 05 Nov 2009 19:40:07 +0100

> On Thu, 2009-11-05 at 11:06 +0100, Eric Dumazet wrote:
>> Speedup ieee80211_remove_interfaces() by factorizing synchronize_rcu() calls
> 
> Jouni will be pleased for his testing... :)
> 
> Looks good to me. Nice simplification too.
> 
> Reviewed-by: Johannes Berg <johannes@sipsolutions.net>
> 

I'll leave it to John to integrate this, thanks guys.
