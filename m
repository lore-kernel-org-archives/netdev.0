From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: enable msi-x for quad-gig boards
Date: Sat, 13 Sep 2008 20:13:24 -0400
Message-ID: <48CC5724.4020407@garzik.org>
References: <> <1219265568-28298-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38137 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937AbYINAN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 20:13:27 -0400
In-Reply-To: <1219265568-28298-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> NX3031 firmware now supports MSI-X interrupts on Quad GbE boards.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 32bb47a..59d6521 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -241,7 +241,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
>  	case NETXEN_BRDTYPE_P3_REF_QG:
>  	case NETXEN_BRDTYPE_P3_4_GB:
>  	case NETXEN_BRDTYPE_P3_4_GB_MM:
> -		adapter->msix_supported = 0;
> +		adapter->msix_supported = !!use_msi_x;
>  		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;

applied


