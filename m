From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon, 05 May 2014 16:31:49 -0400 (EDT)
Message-ID: <20140505.163149.1761978802401215.davem@davemloft.net>
References: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755362AbaEEUbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 16:31:51 -0400
In-Reply-To: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  5 May 2014 13:07:36 -0700

> This series contains updates to e1000e only.
> 
> David provides four fixes for e1000e, first is a workaround for a hardware
> erratum on 82579 devices which experienced packet loss in gigabit and 100
> speeds when interconnect between the PHY and MAC is exiting K1 power saving
> state.  Second expands the scope of a workaround to include i217 and i218
> parts as well to address over aggressive transmit behavior when connecting
> at 10Mbs half-duplex.  Next is to resolve a reported link flap issue on
> 82579 parts which was root caused as an interoperability problem between
> 82579 and at least some Broadcom PHYs in the Energy Efficient Ethernet wake
> mechanism.  Lastly, restricts the workaround of putting the PHY into MDIO
> slow mode to access the PHY id to relevant parts since this issue has been
> fixed on the newer hardware.
> 
> The following are changes since commit 9d4619c492c84e4c1e6d7127f1cbf55da04599d0:
>   Altera TSE: ALTERA_TSE should depend on HAS_DMA
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
