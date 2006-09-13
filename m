From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 6/12] smc911x: Unneeded spinlocks around smc911x_enable
Date: Wed, 13 Sep 2006 21:02:02 +0200
Message-ID: <20060913190202.GC25007@electric-eye.fr.zoreil.com>
References: <200609132108.16835.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:17292 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751112AbWIMTFD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:03 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132108.16835.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> is unneeded...
[...]
> -	spin_lock_irqsave(&lp->lock, flags);

The variable "flags" is not used any more.

-- 
Ueimor
