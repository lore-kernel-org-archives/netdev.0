From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 32/41] lockdep: fix smc91x
Date: Wed, 16 Aug 2006 16:05:19 -0400
Message-ID: <44E37A7F.6020709@garzik.org>
References: <200608150600.k7F60KYL012708@shell0.pdx.osdl.net> <Pine.LNX.4.64.0608161526260.3494@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	rmk+lkml@arm.linux.org.uk, rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33161 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932189AbWHPUFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 16:05:31 -0400
To: Nicolas Pitre <nico@cam.org>
In-Reply-To: <Pine.LNX.4.64.0608161526260.3494@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Pitre wrote:
> On Mon, 14 Aug 2006, akpm@osdl.org wrote:
> 
>> From: Russell King <rmk+lkml@arm.linux.org.uk>
>>
>> When booting using root-nfs, I'm seeing (independently) two lockdep dumps
>> in the smc91x driver.  The patch below fixes both.  Both dumps look like
>> real locking issues.
>>
>> Nico - please review and ack if you think the patch is correct.
> 
> The lock validator is rightfully complaining and the patch is correct.
> 
> Acked-by: Nicolas Pitre <nico@cam.org>

thanks

	Jeff



