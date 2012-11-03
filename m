From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: avoid a test in ip_rt_put()
Date: Sat, 03 Nov 2012 15:00:08 -0400 (EDT)
Message-ID: <20121103.150008.1620360914018927907.davem@davemloft.net>
References: <1351499603.7394.199.camel@edumazet-glaptop>
	<1351501746.8221.12.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab2KCTAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:00:09 -0400
In-Reply-To: <1351501746.8221.12.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 29 Oct 2012 17:09:06 +0800

> On Mon, 2012-10-29 at 09:33 +0100, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> We can save a test in ip_rt_put(), considering dst_release() accepts
>> a NULL parameter, and dst is first element in rtable.
>> 
>> Add a BUILD_BUG_ON() to catch any change that could break this
>> assertion.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Cong Wang <amwang@redhat.com>
> 
> Acked-by: Cong Wang <amwang@redhat.com>

Applied.
