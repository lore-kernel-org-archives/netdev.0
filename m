From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 10/12] smc911x: phy_configure releases spinlocks before grabing
Date: Wed, 13 Sep 2006 21:02:19 +0200
Message-ID: <20060913190219.GE25007@electric-eye.fr.zoreil.com>
References: <200609132132.51674.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:17548 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751113AbWIMTFD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:03 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132132.51674.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> @@ -1040,6 +1037,7 @@
>  
>  smc911x_phy_configure_exit:
>  	spin_unlock_irqrestore(&lp->lock, flags);

The change is fine but I'd rename this one as
${some_random_string_}out_unlock as well.

-- 
Ueimor
