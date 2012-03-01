From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] mpc836x: fix failed phy detection for ucc ethernet on MDS
Date: Thu, 1 Mar 2012 16:06:35 -0600
Message-ID: <0CFFA9FB-E2D0-4CC3-A430-10692B62B9B0@freescale.com>
References: <1330345501-24949-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <benh@kernel.crashing.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:56329
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754371Ab2CAWGr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 17:06:47 -0500
In-Reply-To: <1330345501-24949-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 27, 2012, at 6:25 AM, Paul Gortmaker wrote:

> The mpc836x_mds platform has been broken since the commit
> 6fe3264945ee63292cdfb27b6e95bc52c603bb09
> 
> [...]

> ---
> 
> [Andy: There may be other boards that could be having this problem
>  git grep -l enet.*ucc arch/powerpc/boot/dts/|xargs grep -L tbi
> shows four possible candidates -- but I've only got the 8360MDS. ]


Shoot. I will go look for those. I suspect I neglected all the UCC-having SOCs in my patch.
