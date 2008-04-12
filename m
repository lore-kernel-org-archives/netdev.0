From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
Date: Sat, 12 Apr 2008 16:28:32 -0400
Message-ID: <48011B70.1020102@garzik.org>
References: <20080327144044.GA8831@ru.mvista.com>	<47EDA6F1.9080206@garzik.org> <20080411092417.57825115@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valentine Barshak <vbarshak@ru.mvista.com>,
	linuxppc-dev@ozlabs.org, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54726 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756472AbYDLU2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 16:28:50 -0400
In-Reply-To: <20080411092417.57825115@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> On Fri, 28 Mar 2008 22:18:25 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Valentine Barshak wrote:
>>> The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
>>> if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
>>> driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
>>> which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
>>> does the same for "ibm,emac-440gx" compatible chips. The workaround forces
>>> clock on -all- EMACs, so we select clock under global emac_phy_map_lock.
>>>
>>> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
>>> ---
>>>  drivers/net/ibm_newemac/core.c |   16 +++++++++++++++-
>>>  drivers/net/ibm_newemac/core.h |    8 ++++++--
>>>  2 files changed, 21 insertions(+), 3 deletions(-)
>> is this for 2.6.25-rc?
> 
> Jeff, can I get an ack from you on this patch, and patch 2 in this
> set?  They depend on a patch in my tree and I'd like to include them in
> my next push to Paul for 2.6.26.

ACK

I had queried the status of these patches, and didn't receive any reply 
initially from my query...


