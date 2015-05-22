From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix a potential deadlock in
 tcp_get_info()
Date: Fri, 22 May 2015 14:21:31 -0400 (EDT)
Message-ID: <20150522.142131.2304669580804588128.davem@davemloft.net>
References: <1432317396.4060.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432317814.4060.132.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432318119.4060.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757816AbbEVSVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:21:35 -0400
In-Reply-To: <1432318119.4060.133.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 May 2015 11:08:39 -0700

> On Fri, 2015-05-22 at 11:03 -0700, Eric Dumazet wrote:
> 
>> Also I am wondering if not explicitly include <linux/u64_stats_sync.h>
>> could break one arch...
> 
> Sorry for the false alarm, we should be good because of snmp.h

Right.
