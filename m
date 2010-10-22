From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2/3] vmxnet3: annotate hwaddr members as __iomem
 pointers
Date: Fri, 22 Oct 2010 10:30:18 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1010221029520.9726@sbhatewara-dev1.eng.vmware.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com> <1287720334-15469-2-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:2269 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755694Ab0JVRaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 13:30:18 -0400
In-Reply-To: <1287720334-15469-2-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Harvey.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

On Thu, 21 Oct 2010, Harvey Harrison wrote:

> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_int.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
> index 46aee6d..8a2f471 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -301,8 +301,8 @@ struct vmxnet3_adapter {
>  	struct net_device              *netdev;
>  	struct pci_dev                 *pdev;
>  
> -	u8				*hw_addr0; /* for BAR 0 */
> -	u8				*hw_addr1; /* for BAR 1 */
> +	u8			__iomem *hw_addr0; /* for BAR 0 */
> +	u8			__iomem *hw_addr1; /* for BAR 1 */
>  
>  	/* feature control */
>  	bool				rxcsum;
> -- 
> 1.7.1
> 
> 
