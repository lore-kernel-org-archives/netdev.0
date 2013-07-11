From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 16:30:01 -0700 (PDT)
Message-ID: <20130711.163001.2048627063903930724.davem@davemloft.net>
References: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
	<1373579547.4600.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	pshelar@nicira.com, jesse@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab3GKXaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 19:30:03 -0400
In-Reply-To: <1373579547.4600.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jul 2013 14:52:27 -0700

> On Thu, 2013-07-11 at 13:12 -0700, Alexander Duyck wrote:
>> This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
>> packets are sent from the interface.
>> 
>> In my case I was able to reproduce the issue by simply sending a ping of
>> 1421 bytes with the gretap interface created on a device with a standard
>> 1500 mtu.
>> 
>> This fix is based on the fact that the tunnel mtu is already adjusted by
>> dev->hard_header_len so it would make sense that any packets being compared
>> against that mtu should also be adjusted by hard_header_len and the tunnel
>> header instead of just the tunnel header.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
...
> Reported-by: Cong Wang <amwang@redhat.com>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
