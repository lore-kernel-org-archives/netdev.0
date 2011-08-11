From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 04/10] 8390: Move the 8390 related drivers
Date: Thu, 11 Aug 2011 14:07:08 +0100
Message-ID: <1313068028.2591.1282.camel@deadeye>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313033278-7337-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@tredhat.com,
	sassmann@redhat.com, Donald Becker <becker@scyld.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alain Malek <alain.malek@cryogen.com>,
	Peter De Schrijver <p2@mind.be>,
	David Huggins-Daines <dhd@debian.org>,
	Wim Dumon <wimpie@kotnet.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	David Hinds <dahinds@users.sourceforge.net>,
	Russell King <linux@arm.linux.org.uk>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5087 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab1HKNHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 09:07:12 -0400
In-Reply-To: <1313033278-7337-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-10 at 20:27 -0700, Jeff Kirsher wrote:
> Moves the drivers for the National Semi-conductor 8390 chipset into
> drivers/net/ethernet/8390/ and the necessary Kconfig and Makefile
> changes.
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/8390/Kconfig
[...]
> +config EL2
> +	tristate "3c503 \"EtherLink II\" support"
> +	depends on ISA
> +	select CRC32
> +	---help---
> +	  If you have a network (Ethernet) card of this type, say Y and read
> +	  the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  To compile this driver as a module, choose M here. The module
> +	  will be called 3c503.
[...]

Minor issue: you add the EL2 config here correctly, but don't remove it
from drivers/net/Kconfig until patch 10.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

