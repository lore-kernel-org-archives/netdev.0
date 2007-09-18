From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] ucc_geth: fix compilation
Date: Tue, 18 Sep 2007 09:04:04 -0500
Message-ID: <E0E78DB4-3A30-4D2D-83EE-B63D6C3A1D53@kernel.crashing.org>
References: <20070912112456.GA15556@localhost.localdomain><20070913152333.GA2381@localhost.localdomain> <C844988E-F6B9-44B9-AB78-C44E19A2E605@kernel.crashing.org> <989B956029373F45A0B8AF029708189001763D1E@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, <linuxppc-dev@ozlabs.org>,
	"netdev" <netdev@vger.kernel.org>
To: "Li Yang-r58472" <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57314 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754993AbXIROCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 10:02:08 -0400
In-Reply-To: <989B956029373F45A0B8AF029708189001763D1E@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 18, 2007, at 3:56 AM, Li Yang-r58472 wrote:

>> -----Original Message-----
>> From: linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org
>> [mailto:linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org]
>> On Behalf Of Kumar Gala
>> Sent: Friday, September 14, 2007 10:08 PM
>> To: Jeff Garzik
>> Cc: linuxppc-dev@ozlabs.org list; netdev
>> Subject: Re: [PATCH] ucc_geth: fix compilation
>>
>>
>> On Sep 13, 2007, at 10:23 AM, Anton Vorontsov wrote:
>>
>>> Currently qe_bd_t is used in the macro call --
>> dma_unmap_single, which
>>> is a no-op on PPC32, thus error is hidden today. Starting
>> with 2.6.24,
>>> macro will be replaced by the empty static function, and
>> erroneous use
>>> of qe_bd_t will trigger compilation error.
>>>
>>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>>> ---
>>
>> Jeff, I'm going to pick this up via the powerpc.git tree
>> since its currently only broken in our for-2.6.24 branch
>> (because of other changes in there).  Any issues?
>
> Kumar,
>
> Kim Phillips has posted the same patch to netdev list before Anton.
> Therefore, I do prefer to use his.  Thanks

No problem.  Jeff seems to have picked up some version of the fix.

- k
