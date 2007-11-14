From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X
 local entry memories when vector allocation fails
Date: Wed, 14 Nov 2007 01:41:16 -0800 (PST)
Message-ID: <20071114.014116.39438204.davem@davemloft.net>
References: <Pine.GSO.4.10.10711140423410.18735-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753650AbXKNJlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:41:16 -0500
In-Reply-To: <Pine.GSO.4.10.10711140423410.18735-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Wed, 14 Nov 2007 04:29:07 -0500 (EST)

> - Fixed memory leak by freeing MSI-X local entry memories when vector allocation
> fails in s2io_add_isr.
> - Added two utility functions remove_msix_isr and remove_inta_isr to eliminate
> code duplication.
> - Incorporated following review comments from Jeff
>         - Removed redundant stats->mem_freed and synchronize_irq call
>         - do_rem_msix_isr is renamed as remove_msix_isr
>         - do_rem_inta_isr is renamed as remove_inta_isr
> 
> - (Resubmit third time)
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

Applied to net-2.6, thanks!
