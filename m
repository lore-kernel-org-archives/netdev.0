From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] bnx2: Use one handler for all MSI-X vectors.
Date: Thu, 19 Jun 2008 16:42:15 -0700 (PDT)
Message-ID: <20080619.164215.175234966.davem@davemloft.net>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
	<1213835132-5698-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754149AbYFSXmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:42:16 -0400
In-Reply-To: <1213835132-5698-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Jun 2008 17:25:28 -0700

> Use the same MSI-X handler to schedule NAPI.  Change the dev_instance
> void pointer to the bnx2_napi struct instead so we can have the proper
> context for each MSI-X vector.
> 
> Add a new bnx2_poll_msix() that is optimized for handling MSI-X
> NAPI polling of rx/tx work only.  Remove the old bnx2_tx_poll() that
> is no longer needed.  Each MSI-X vector handles 1 tx and 1 rx ring.
> The first vector handles link events as well.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied to net-next-2.6
