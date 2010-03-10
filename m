From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 3/4] bnx2x: change smp_mb() comment to conform the
 true
Date: Wed, 10 Mar 2010 18:01:16 +0200
Message-ID: <1268236876.30985.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
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
Received: from mms3.broadcom.com ([216.31.210.19]:3418 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756787Ab0CJQBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 11:01:37 -0500
In-Reply-To: <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
> Access to fp->tx_bp_prod is protected by __netif_tx_lock,
> smp_mb() is not needed for that.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>


