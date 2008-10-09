From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/8 2.6.28] cxgb3 - Allocate multiqueues at init time
Date: Thu, 09 Oct 2008 10:57:54 -0700
Message-ID: <48EE4622.4080207@chelsio.com>
References: <20081009003402.13315.18192.stgit@speedy5> <20081008.174202.160320028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31671 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760089AbYJIR6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 13:58:16 -0400
In-Reply-To: <20081008.174202.160320028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Wed, 08 Oct 2008 17:34:02 -0700
>
>   
>> Allocate a queue set per core, up to the maximum of available qsets.
>> Share the queue sets on multi port adapters.
>> Rename MSI-X interrupt vectors ethX-N, N being the queue set number.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>     
>
> Applied, but...
>
> This "num processors" logic and policy belongs in some generic place.
> Perhaps "num_possible_cpus()" is more appropriate, who knows right?
>   

I'll look into it.

Cheers,
Divy

