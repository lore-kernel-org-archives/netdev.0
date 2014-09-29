From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cleanup and document skb fclone layout
Date: Mon, 29 Sep 2014 14:59:08 -0400 (EDT)
Message-ID: <20140929.145908.1231412213790040437.davem@davemloft.net>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412011416.30721.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbaI2S7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:59:09 -0400
In-Reply-To: <1412011416.30721.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Sep 2014 10:23:36 -0700

> On Sat, 2014-09-27 at 16:25 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Lets use a proper structure to clearly document and implement
>> skb fast clones.
>> 
>> Then, we might experiment more easily alternative layouts.
>> 
>> This patch adds a new skb_fclone_busy() helper, used by tcp and xfrm.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>>  include/linux/skbuff.h |   25 ++++++++++++++++++++++
>>  net/core/skbuff.c      |   44 +++++++++++++++++++--------------------
>>  net/ipv4/tcp_output.c  |    5 ----
>>  net/xfrm/xfrm_policy.c |    4 ---
>>  4 files changed, 49 insertions(+), 29 deletions(-)
> 
> 
> I'll rebase this patch and send a v2.

Thanks.
