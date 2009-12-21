From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 01/12] ixgbevf: Macros, data structures, useful
	defines and registers
Date: Mon, 21 Dec 2009 18:38:22 +0000
Message-ID: <1261420702.2782.3.camel@achroite.uk.solarflarecom.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20247 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbZLUSi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 13:38:26 -0500
In-Reply-To: <20091218225043.10698.58897.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 14:51 -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> These two headers define the commonly used macros, data structures,
> register bits and register offsets used by the ixgbevf driver on the
> 82599 virtual function device
> 
[...]
> diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
> new file mode 100644
> index 0000000..b111771
> --- /dev/null
> +++ b/drivers/net/ixgbevf/defines.h
[...]
> +/* Check whether address is multicast.  This is little-endian specific check.*/
> +#define IXGBE_IS_MULTICAST(Address) \
> +	(bool)(((u8 *)(Address))[0] & ((u8)0x01))
> +
> +/* Check whether an address is broadcast. */
> +#define IXGBE_IS_BROADCAST(Address)              \
> +	((((u8 *)(Address))[0] == ((u8)0xFF)) && \
> +	 (((u8 *)(Address))[1] == ((u8)0xFF)))
[...]

Why not use is_multicast_ether_addr() and  is_broadcast_ether_addr()?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

