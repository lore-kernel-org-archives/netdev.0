From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 1/4] bnx2x: use smp_mb() to keep ordering of read
 write operations
Date: Wed, 10 Mar 2010 17:59:44 +0200
Message-ID: <1268236784.30985.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3275 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756783Ab0CJQAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 11:00:05 -0500
In-Reply-To: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
> Since we want to keep ordering of write to fp->bd_tx_cons and
> netif_tx_queue_stopped(txq), what is read of txq->state, we have to use
> general memory barrier.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Singed-of-by: Eilon Greenstein <eilong@broadcom.com>


