From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: use RNC mode for R8A7790
Date: Fri, 30 May 2014 17:47:00 -0700 (PDT)
Message-ID: <20140530.174700.1334587282764300529.davem@davemloft.net>
References: <1401458186-29985-1-git-send-email-ben.dooks@codethink.co.uk>
	<53888EEA.7060702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, netdev@vger.kernel.org,
	linux-kernel@codethink.co.uk, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934638AbaEaArB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:47:01 -0400
In-Reply-To: <53888EEA.7060702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 30 May 2014 18:00:10 +0400

> Hello.
> 
> On 05/30/2014 05:56 PM, Ben Dooks wrote:
> 
>    The subject should have "R8A779x".
> 
>> The current behaviour of the sh_eth driver is not to use the RNC bit
>> for the receive ring. This means that every packet recieved is not
>> only
>> generating an IRQ but it also stops the receive ring DMA as well until
>> the driver re-enables it after unloading the packet.
>>
>> This means that a number of the following errors are generated due to
>> the receive packet FIFO overflowing due to nowhere to put packets:
>>
>> 	net eth0: Receive FIFO Overflow
>>
>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>> root filesystem and the driver has not failed yet. It is not yet known
>> why this is not set for R8A779x operation (Feedback on this issue or
>> other testing is welcome)
> 
>    I have provided such feedback (and many people provided testing), so
>    that the last sentence doesn't make sense anymore.
> 
>> There are further test reports from Sergei Shtylov and others for
>> both the R8A7790 and R8A7791.
> 
>> Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
>    Other than the remarks above:
> 
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Ben, please fix the commit message and resubmit,
