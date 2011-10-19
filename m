From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Wed, 19 Oct 2011 15:32:08 -0400 (EDT)
Message-ID: <20111019.153208.1743995025598236810.davem@davemloft.net>
References: <20111014055406.GP1830@secunet.com>
	<20111017121805.GR1830@secunet.com>
	<4E9E9366.1050702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab1JSTcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 15:32:24 -0400
In-Reply-To: <4E9E9366.1050702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Wed, 19 Oct 2011 17:07:50 +0800

> 2011.10.17 20:18, Steffen Klassert wrote:
>> On Fri, Oct 14, 2011 at 07:54:06AM +0200, Steffen Klassert wrote:
>>> On Thu, Oct 13, 2011 at 01:58:08PM -0400, David Miller wrote:
>>>>
>>>> Please find out exactly why dst->obsolete is non-zero on a freshly
>>>> looked up route.  It's unexpected.
>>>
>>> Hm, on a slow path route lookup e.g. __mkroute_output() calls
>>> rt_dst_alloc() which initializes dst->obsolete to -1.
>> 
>> Just a follow up:
>> git commit d11a4dc18 (ipv4: check rt_genid in dst_check)
>> changed the initialization value of dst->obsolete from
>> 0 to -1.
>> --
> 
> Anybody give any suggestion?

I'm really busy but will look at this soon.
