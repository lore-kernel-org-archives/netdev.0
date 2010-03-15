From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bnx2x: use smp_mb() to keep ordering of read write
 operations
Date: Mon, 15 Mar 2010 15:47:24 -0700 (PDT)
Message-ID: <20100315.154724.267126667.davem@davemloft.net>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
	<1268236784.30985.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, vladz@broadcom.com,
	mchan@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936992Ab0COWrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:02 -0400
In-Reply-To: <1268236784.30985.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 10 Mar 2010 17:59:44 +0200

> On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
>> Since we want to keep ordering of write to fp->bd_tx_cons and
>> netif_tx_queue_stopped(txq), what is read of txq->state, we have to use
>> general memory barrier.
>> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Singed-of-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
