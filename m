From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH 0/2] amd-xgbe: AMD XGBE driver updates 2016-11-14
Date: Mon, 14 Nov 2016 16:42:53 -0600
Message-ID: <5139f826-97a4-512e-7948-2db9d195cb4c@amd.com>
References: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <christophe.jaillet@wanadoo.fr>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0060.outbound.protection.outlook.com ([104.47.33.60]:19776
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754304AbcKNWnC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:43:02 -0500
In-Reply-To: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 4:28 PM, Tom Lendacky wrote:
> This patch series addresses some minor issues found in the recently
> accepted patch series for the AMD XGBE driver.
> 
> The following fixes are included in this driver update series:
> 
> - Fix how a mask is applied to a Clause 37 register value
> - Fix some coccinelle identified warnings
> 
> This patch series is based on net-next.

David,

I forgot to include the net-next repo name in the subject, please
ignore this series and I'll resend.

Thanks,
Tom

> 
> ---
> 
> Tom Lendacky (2):
>       amd-xgbe: Fix mask appliciation for Clause 37 register
>       amd-xgbe: Fix up some coccinelle identified warnings
> 
> 
>  drivers/net/ethernet/amd/xgbe/xgbe-mdio.c   |    4 ++--
>  drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    5 ++---
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
