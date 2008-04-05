From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Better MWI workaround for 21143 rev 65 chip errata
Date: Sat, 5 Apr 2008 12:19:31 -0600
Message-ID: <20080405181931.GA30312@colo.lackof.org>
References: <20080325113909.82BF8C2B76@solo.franken.de> <20080404064216.GA8791@colo.lackof.org> <47F6A698.1010400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, kyle@parisc-linux.org,
	zero@colonel-panic.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:34609 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827AbYDESTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 14:19:42 -0400
Content-Disposition: inline
In-Reply-To: <47F6A698.1010400@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 04, 2008 at 06:07:20PM -0400, Jeff Garzik wrote:
> Grant Grundler wrote:
>> On Tue, Mar 25, 2008 at 12:39:09PM +0100, Thomas Bogendoerfer wrote:
>>> From: Peter Horton <zero@colonel-panic.org>
>>>
>>> This patch works around the MWI bug on the DC21143 rev 65 Tulip by
>>> ensuring that the receive buffers don't end on a cache line boundary
>>> (as documented in the errata).
>>>
>>> This patch is required for the MIPS based Cobalt Qube/RaQ as
>>> supporting the extra PCI commands seems to reduce the chance of a hard
>>> lockup between the Tulip and the PCI bridge.
>>>
>>> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
>> Acked-by: Grant Grundler <grundler@parisc-linux.org>
>> thanks!
>> I haven't tested this but it looks correct to me.
>
> Wanna give it a quick test then someone bounce me the patch?  :)  I don't 
> have the original.

Tested on j6000 (parisc) with 2.6.25-rc6 + gcc 4.2.
Seems to be working fine.
I'll bounce it next.

thanks,
grant
