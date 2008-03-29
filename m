From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
Date: Fri, 28 Mar 2008 22:18:25 -0400
Message-ID: <47EDA6F1.9080206@garzik.org>
References: <20080327144044.GA8831@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, benh@kernel.crashing.org,
	jwboyer@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47964 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198AbYC2CSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:18:35 -0400
In-Reply-To: <20080327144044.GA8831@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valentine Barshak wrote:
> The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
> if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
> driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
> which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
> does the same for "ibm,emac-440gx" compatible chips. The workaround forces
> clock on -all- EMACs, so we select clock under global emac_phy_map_lock.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> ---
>  drivers/net/ibm_newemac/core.c |   16 +++++++++++++++-
>  drivers/net/ibm_newemac/core.h |    8 ++++++--
>  2 files changed, 21 insertions(+), 3 deletions(-)

is this for 2.6.25-rc?


