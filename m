From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 11/12] smc911x: Undocumented interrupt now reserved
Date: Wed, 13 Sep 2006 21:02:28 +0200
Message-ID: <20060913190228.GF25007@electric-eye.fr.zoreil.com>
References: <200609132137.39606.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:18572 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751117AbWIMTFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:09 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132137.39606.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> @@ -1127,7 +1125,7 @@
>  			lp->stats.rx_dropped+=SMC_GET_RX_DROP();
>  		 }
>  		/* Undocumented interrupt-what is the right thing to do here? */
> -		if (status & INT_STS_RXDF_INT_) {
> +		if (IS_REV_A(lp->revision) && status & INT_STS_RXDF_INT_) {

Extra parenthesis please.

-- 
Ueimor
