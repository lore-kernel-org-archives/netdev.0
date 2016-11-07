From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] net: xgbe: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 7 Nov 2016 08:31:32 -0600
Message-ID: <e1720787-40d7-f8c8-a596-fab007d9b491@amd.com>
References: <1478440624-23565-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0074.outbound.protection.outlook.com ([104.47.32.74]:44437
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752952AbcKGObm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 09:31:42 -0500
In-Reply-To: <1478440624-23565-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2016 07:57 AM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   68 ++++++++++++++------------
>  1 files changed, 37 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
> index 46c959b..920566a 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
