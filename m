From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Use netdev_<level>, dev_<level>,
 pr_<level>
Date: Thu, 03 Jun 2010 20:20:05 -0700
Message-ID: <1275621605.1703.38.camel@Joe-Laptop.home>
References: <20100604025225.16120.30293.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2644 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab0FDDUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 23:20:08 -0400
In-Reply-To: <20100604025225.16120.30293.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 19:53 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>

Hi Emil.

> This patch is alternative to a previous patch submitted by Joe Perches.

Why eliminate all the adapter->msg_enable tests?

There are many changes like this. For instance:

>  	if (link_up && (link_speed == IXGBE_LINK_SPEED_1GB_FULL))
> -		netif_info(adapter, hw, adapter->netdev, "Smartspeed has"
> -			" downgraded the link speed from the maximum"
> -			" advertised\n");
> +		e_info("Smartspeed has downgraded the link speed from "
> +		       "the maximum advertised\n");

This was only printed when NETIF_MSG_HW was set,
now it's always printed.


