From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]bnx2x: tx_has_work should not wait for FW
Date: Mon, 26 Jan 2009 12:36:50 -0800 (PST)
Message-ID: <20090126.123650.35539851.davem@davemloft.net>
References: <1232988956.18353.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752056AbZAZUgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:36:48 -0500
In-Reply-To: <1232988956.18353.3.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 26 Jan 2009 18:55:56 +0200

> The current tx_has_work waited until all packets sent by the driver are marked
> as completed by the FW. This is too greedy and it causes the bnx2x_poll to spin
> in vain. The driver should only check that all packets FW already completed are
> freed - only in unload flow the driver should make sure that transmit queue is
> empty
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
