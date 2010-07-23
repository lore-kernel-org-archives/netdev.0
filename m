From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 3c59x: fix leak of iomaps
Date: Fri, 23 Jul 2010 13:06:13 -0700 (PDT)
Message-ID: <20100723.130613.242150222.davem@davemloft.net>
References: <1279903485-28247-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de, eric.dumazet@gmail.com,
	ben@decadent.org.uk, adobriyan@gmail.com, joe@perches.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760517Ab0GWUF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 16:05:56 -0400
In-Reply-To: <1279903485-28247-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri, 23 Jul 2010 20:44:44 +0400

> If vortex_probe1() fails we should unmap ioaddr mapped earlier.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.  Thanks for following up on this.
