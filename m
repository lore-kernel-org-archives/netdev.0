From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 08:04:29 -0700
Message-ID: <20060526080429.2ebf8c08@localhost.localdomain>
References: <Pine.LNX.4.33.0605250347050.5844-100000@unmsrvr>
	<20060525093349.3f42220a@dxpl.pdx.osdl.net>
	<1148652872.3453.100.camel@arya.linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62094 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750865AbWEZPFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 11:05:18 -0400
To: pradeep@linsyssoft.com
In-Reply-To: <1148652872.3453.100.camel@arya.linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 May 2006 14:14:32 +0000
Pradeep Dalvi <pradeep@linsyssoft.com> wrote:

> Following are the minor changes for [PATCH 1/9] in accordance with the
> given suggestions.
> 
> Regards,
> pradeep
> 
> diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
> linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
> --- linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
> 2006-05-25 02:43:22.000000000 -0700
> +++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
> 2006-05-26 04:05:34.000000000 -0700
> @@ -145,7 +145,7 @@
> 
>                 ecmd->port = PORT_TP;
> 
> -               if (port->state) {
> +               if (dev->flags & IFF_UP) {

	if (netif_running(dev)) {
