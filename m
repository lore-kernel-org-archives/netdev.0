From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 8/12] smc911x: Fix external phy detect routine
Date: Wed, 13 Sep 2006 21:02:10 +0200
Message-ID: <20060913190210.GD25007@electric-eye.fr.zoreil.com>
References: <200609132119.18888.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:19084 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751115AbWIMTFK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:10 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132119.18888.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
> 
> 
> 9115-an1212.pdf, page 23 -> http://www.smsc.com/main/anpdf/an1212.pdf
> 
> "The existence of external PHYs is determined by reading 
> the same two PHY registers at PHY addresses 0x02 through 0x30. If values of 
[...]
> -				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
> +				for (phyaddr = 2; phyaddr < 30; ++phyaddr) {

Is 30 inclusive or not ?

-- 
Ueimor
