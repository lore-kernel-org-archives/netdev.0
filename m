From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Better MWI workaround for 21143 rev 65 chip errata
Date: Fri, 04 Apr 2008 18:07:20 -0400
Message-ID: <47F6A698.1010400@pobox.com>
References: <20080325113909.82BF8C2B76@solo.franken.de> <20080404064216.GA8791@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, kyle@parisc-linux.org,
	zero@colonel-panic.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51460 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbYDDWH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 18:07:28 -0400
In-Reply-To: <20080404064216.GA8791@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> On Tue, Mar 25, 2008 at 12:39:09PM +0100, Thomas Bogendoerfer wrote:
>> From: Peter Horton <zero@colonel-panic.org>
>>
>> This patch works around the MWI bug on the DC21143 rev 65 Tulip by
>> ensuring that the receive buffers don't end on a cache line boundary
>> (as documented in the errata).
>>
>> This patch is required for the MIPS based Cobalt Qube/RaQ as
>> supporting the extra PCI commands seems to reduce the chance of a hard
>> lockup between the Tulip and the PCI bridge.
>>
>> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
> 
> thanks!
> I haven't tested this but it looks correct to me.

Wanna give it a quick test then someone bounce me the patch?  :)  I 
don't have the original.

	Jeff


