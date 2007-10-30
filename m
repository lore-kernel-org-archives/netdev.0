From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] Blackfin EMAC driver: Fix Ethernet communication
 bug (dupliated and lost packets)
Date: Tue, 30 Oct 2007 14:32:41 -0400
Message-ID: <472778C9.5040408@garzik.org>
References: <1193735049-7070-1-git-send-email-bryan.wu@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: Bryan Wu <bryan.wu@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbXJ3Scn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:32:43 -0400
In-Reply-To: <1193735049-7070-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Wu wrote:
> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> Fix Ethernet communication bug(dupliated and lost packets)
> in RMII PHY mode- dont call mac_disable and mac_enable during
> 10/100 REFCLK changes - mac_enable screws up the DMA descriptor chain
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> ---
>  drivers/net/bfin_mac.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)

applied


