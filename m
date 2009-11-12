From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 2/2] au1000-eth: convert to platform_driver model
Date: Thu, 12 Nov 2009 17:42:02 +0100
Message-ID: <20091112164202.GB10372@linux-mips.org>
References: <200911100113.38685.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips <linux-mips@linux-mips.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:50530 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbZKLQmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 11:42:01 -0500
Received: from localhost.localdomain ([127.0.0.1]:57570 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-FAIL) by ftp.linux-mips.org with ESMTP
	id S1493108AbZKLQmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 17:42:00 +0100
Content-Disposition: inline
In-Reply-To: <200911100113.38685.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 01:13:38AM +0100, Florian Fainelli wrote:

> 
> This patch converts the au1000-eth driver to become a full
> platform-driver as it ought to be. We now pass PHY-speficic
> configurations through platform_data but for compatibility
> the driver still assumes the default settings (search for PHY1 on
> MAC0) when no platform_data is passed. Tested on my MTX-1 board.
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Queued for 2.6.33.  Thanks everybody!

  Ralf
