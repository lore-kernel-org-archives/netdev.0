From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] bnx2x: change smp_mb() comment to conform the true
Date: Mon, 15 Mar 2010 15:47:34 -0700 (PDT)
Message-ID: <20100315.154734.205398106.davem@davemloft.net>
References: <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
	<1268153703-4186-3-git-send-email-sgruszka@redhat.com>
	<1268236876.30985.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, vladz@broadcom.com,
	mchan@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937009Ab0COWrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:14 -0400
In-Reply-To: <1268236876.30985.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 10 Mar 2010 18:01:16 +0200

> On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
>> Access to fp->tx_bp_prod is protected by __netif_tx_lock,
>> smp_mb() is not needed for that.
>> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
