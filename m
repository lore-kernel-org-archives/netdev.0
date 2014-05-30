From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: use RNC mode for R8A7790
Date: Fri, 30 May 2014 15:09:54 +0100
Message-ID: <53889132.7020104@codethink.co.uk>
References: <1401458186-29985-1-git-send-email-ben.dooks@codethink.co.uk> <53888EEA.7060702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@codethink.co.uk, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34136 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933023AbaE3OKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:10:01 -0400
In-Reply-To: <53888EEA.7060702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/05/14 15:00, Sergei Shtylyov wrote:
> Hello.
> 
> On 05/30/2014 05:56 PM, Ben Dooks wrote:
> 
>    The subject should have "R8A779x".
> 
>> The current behaviour of the sh_eth driver is not to use the RNC bit
>> for the receive ring. This means that every packet recieved is not only
>> generating an IRQ but it also stops the receive ring DMA as well until
>> the driver re-enables it after unloading the packet.
>>
>> This means that a number of the following errors are generated due to
>> the receive packet FIFO overflowing due to nowhere to put packets:
>>
>>     net eth0: Receive FIFO Overflow
>>
>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>> root filesystem and the driver has not failed yet. It is not yet known
>> why this is not set for R8A779x operation (Feedback on this issue or
>> other testing is welcome)
> 
>    I have provided such feedback (and many people provided testing), so
> that the last sentence doesn't make sense anymore.

I suppose it could be removed, it depends on how pedantic people
want to be with the changelogs.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
