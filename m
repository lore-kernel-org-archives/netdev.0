From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 05:40:11 -0400 (EDT)
Message-ID: <20120320.054011.1296392581050573170.davem@davemloft.net>
References: <20120320075846.GF29891@secunet.com>
	<1332232570-17424-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120320085405.GG29891@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab2CTJk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 05:40:29 -0400
In-Reply-To: <20120320085405.GG29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 20 Mar 2012 09:54:05 +0100

> On Tue, Mar 20, 2012 at 04:36:10PM +0800, Gao feng wrote:
>> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
>> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
>> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
>> This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent
>> 
>> Fix this by reserve headroom for dst_exthdrlen.
>> 
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable, thanks.

 
