From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] bnx2: Check netif_running() in all
 ethtool operations.
Date: Thu, 09 Oct 2008 12:22:10 -0700 (PDT)
Message-ID: <20081009.122210.120302203.davem@davemloft.net>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
	<1223572568-1298-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756080AbYJITWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:22:34 -0400
In-Reply-To: <1223572568-1298-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu,  9 Oct 2008 10:16:04 -0700

> We need to check netif_running() state in most ethtool operations
> and properly handle the !netif_running() state where the chip is
> in an uninitailzed state or low power state that may not accept
> any MMIO.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied, but I wonder if this will trip people up who invoke
ethtool to set a specific link setting before bringing the
device up?
