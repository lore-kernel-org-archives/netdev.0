From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] fix drivers/net/irda/ali-ircc.c:ali_ircc_init()
Date: Sat, 08 Jul 2006 13:32:57 -0700 (PDT)
Message-ID: <20060708.133257.04463157.davem@davemloft.net>
References: <20060708012800.GH26941@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37341
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030352AbWGHUdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:33:13 -0400
To: bunk@stusta.de
In-Reply-To: <20060708012800.GH26941@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 8 Jul 2006 03:28:05 +0200

> The Coverity checker spotted, that from the changes from commit 
> 898b1d16f8230fb912a0c2248df685735c6ceda3 the
>        if (ret)
>                platform_driver_unregister(&ali_ircc_driver);
> was dead code.
> 
> This patch changes this function to what seems to have been the 
> intention.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
