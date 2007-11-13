From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] netfilter : xt_time should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 13:07:42 +0100
Message-ID: <4739938E.6010905@trash.net>
References: <47398ADD.2030509@cosmosbay.com> <20071113.035019.268404275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43482 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXKMMIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 07:08:25 -0500
In-Reply-To: <20071113.035019.268404275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 13 Nov 2007 12:30:37 +0100
> 
>> It is not correct to assume one can get nsec from a ktime directly by 
>> using .tv64 field.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Patrick, this is very clearly a correct bug fix, so I'm
> going to apply this directly.


Thanks, thats obviously correct. Still, I would prefer if
people would CC netfilter-devel and myself, it has become
a bad habit lately especially to skip netfilter-devel.

