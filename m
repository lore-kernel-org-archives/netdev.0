From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next v2 28/71] 8139*/atp/r8169/sc92031: Move the Realtek
 drivers
Date: Tue, 02 Aug 2011 01:24:54 +0100
Message-ID: <1312244694.2591.42.camel@deadeye>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Donald Becker <becker@scyld.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15927 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab1HBAZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 20:25:06 -0400
In-Reply-To: <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-07-30 at 20:26 -0700, Jeff Kirsher wrote:
> Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
> the necessary Kconfig and Makefile changes.
[...]

Does it really make sense to move the pci-skeleton driver?  Although it
includes hardware access specific to RTL8139 chips, that's not really
the point of it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

