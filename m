From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: am79c961a: avoid %? in inline assembly
Date: Mon, 8 Feb 2016 15:45:59 +0000
Message-ID: <20160208154559.GM10826@n2100.arm.linux.org.uk>
References: <1454942025-2779812-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:37840 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbcBHPqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 10:46:14 -0500
Content-Disposition: inline
In-Reply-To: <1454942025-2779812-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2016 at 03:33:42PM +0100, Arnd Bergmann wrote:
> The am79c961a.c driver fails to build with clang because of an
> unusual inline assembly construct:
> 
> drivers/net/ethernet/amd/am79c961a.c:53:7: error: invalid % escape in inline assembly string
>  "str%?h        %1, [%2]        @ NET_RAP\n\t"
> 
> The same change has been done a decade ago in arch/arm as of
> 6a39dd6222dd ("[ARM] 3759/2: Remove uses of %?"), but apparently
> some drivers were missed.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Thanks Arnd.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
