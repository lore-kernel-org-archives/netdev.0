From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 0/3 v2] net: various tilegx networking fixes
Date: Wed, 18 Jul 2012 15:22:12 -0400
Message-ID: <50070CE4.7040704@tilera.com>
References: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com> <20120718.113623.984635805289135415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:25966 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755740Ab2GRTWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:22:14 -0400
In-Reply-To: <20120718.113623.984635805289135415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 2:36 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Sun, 1 Jul 2012 14:43:47 -0400
>
>> The tree is at:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git net
>>
>> Chris Metcalf (3):
>>       net: tilegx driver bugfix (be explicit about percpu queue number)
>>       tilegx net driver: handle payload data not in frags
>>       tilegx net: use eth_hw_addr_random(), not random_ether_addr()
> These changes look fine, but when I pull from your tree I get tons of
> totally unrelated stuff and a merge conflict in this driver.
>
> Can you put together a clean pull against net-next?

The merge conflict was against Joe Perches' bombing of random_ether_addr()
to eth_random_addr().  I left in my change to convert that again to be
eth_hw_addr_random(), which naively seems like a better API, and sets
NET_ADDR_RANDOM, which is presumably a good thing.

I recreated the tree to be branched off of net-next. ( I had originally
created it off of Linus's tree, which in retrospect doesn't make much
sense.)  Please try to pull again - thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
