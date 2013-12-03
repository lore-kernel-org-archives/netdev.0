From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add more supoprt for bonding netlink
 attributes
Date: Mon, 2 Dec 2013 23:54:56 -0800
Message-ID: <20131202235456.14e68d53@nehalam.linuxnetplumber.net>
References: <20131107103609.27546.20194.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:63548 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3LCHzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 02:55:00 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so19619216pdj.22
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 23:54:59 -0800 (PST)
In-Reply-To: <20131107103609.27546.20194.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Nov 2013 02:36:09 -0800
Scott Feldman <sfeldma@cumulusnetworks.com> wrote:

> Add get/set support for the following bonding attributes:
> 
> miimon
> updelay
> downdelay
> use_carrier
> arp_interval
> arp_ip_target
> arp_validate
> arp_all_targets
> 
> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
> ---
>  include/linux/if_link.h |    8 +++
>  ip/iplink_bond.c        |  134 ++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 140 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index a485920..69e0353 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -329,6 +329,14 @@ enum {
>  	IFLA_BOND_UNSPEC,
>  	IFLA_BOND_MODE,
>  	IFLA_BOND_ACTIVE_SLAVE,
> +        IFLA_BOND_MIIMON,
> +        IFLA_BOND_UPDELAY,
> +        IFLA_BOND_DOWNDELAY,
> +        IFLA_BOND_USE_CARRIER,
> +        IFLA_BOND_ARP_INTERVAL,
> +        IFLA_BOND_ARP_IP_TARGET,
> +        IFLA_BOND_ARP_VALIDATE,
> +        IFLA_BOND_ARP_ALL_TARGETS,
>  	__IFLA_BOND_MAX,
>  };
>  

Since these header file patches are not even in net-next. Please resubmit when
net-next reopens and the kernel part is done.
