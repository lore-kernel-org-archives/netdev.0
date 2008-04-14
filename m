From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Mon, 14 Apr 2008 09:58:16 -0500
Message-ID: <DFDD56A6-BDA5-40CA-9F85-032330B0ACDD@kernel.crashing.org>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org> <20080411160654.GA25506@polina.dev.rtsoft.ru> <47FF9665.7020403@freescale.com> <20080411170657.GA15270@polina.dev.rtsoft.ru> <20080411171109.GA16119@polina.dev.rtsoft.ru> <47FF9BFE.5000201@freescale.com> <20080411172106.GA17786@polina.dev.rtsoft.ru> <20080411173100.GA20439@polina.dev.rtsoft.ru> <6B2293E0-BE5E-4C2E-9A48-4E91079A7422@kernel.crashing.org> <4803708B.1070009@freescale.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39172 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389AbYDNO7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 10:59:08 -0400
In-Reply-To: <4803708B.1070009@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 14, 2008, at 9:56 AM, Timur Tabi wrote:
> Kumar Gala wrote:
>
>> I say leave as you have it (UCC1 == cell-index = <1>).
>>
>> Changing it so cell-index = <0> is just more confusing w/regards to
>> the docs.
>
> I don't see anything in booting-without-of.txt that requires cell- 
> index to start
> at 0, however, the only other device that starts at 1 is SATA.  Even  
> the SSI
> starts at 0:
>
>       - cell-index	  : the SSI, <0> = SSI1, <1> = SSI2, and so on
>
> Although I don't want to make more work for Anton, my vote is to  
> have cell-index
> start at 0.  That is the convention.  It's too late to fix SATA, but  
> at least we
> can avoid making it worse.

I use cell-index starting at 1 for PCI to match our docs.

I'll take Anton's last patch.

- k
