From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: Fixing EEH handlers
Date: Fri, 11 Dec 2009 15:05:23 -0800
Message-ID: <4B22D033.40105@chelsio.com>
References: <1260471817-7184-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17063 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395AbZLKXOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:14:17 -0500
In-Reply-To: <1260471817-7184-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

leitao@linux.vnet.ibm.com wrote:
>
> After commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, the EEH
> is not working proplery on cxgb3.
>
> This patch fixes it, always saving the PCI state after a recovery,
> in order to allow further reoveries.
>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
>

Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>  drivers/net/cxgb3/cxgb3_main.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/cxgb3/cxgb3_main.c 
> b/drivers/net/cxgb3/cxgb3_main.c
> index cef3f88..89bec9c 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -2860,6 +2860,7 @@ static int t3_reenable_adapter(struct adapter 
> *adapter)
>         }
>         pci_set_master(adapter->pdev);
>         pci_restore_state(adapter->pdev);
> +       pci_save_state(adapter->pdev);
>
>         /* Free sge resources */
>         t3_free_sge_resources(adapter);
> --
> 1.6.0.2
>

