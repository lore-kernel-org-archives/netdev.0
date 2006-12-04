From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 05 Dec 2006 08:16:39 +1100
Message-ID: <1165266999.29784.20.camel@localhost.localdomain>
References: <20060915201538.GA28483@lucciola.windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50684 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937179AbWLDVQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 16:16:50 -0500
To: Amy Fong <amy.fong@windriver.com>
In-Reply-To: <20060915201538.GA28483@lucciola.windriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-15 at 16:15 -0400, Amy Fong wrote:
> [PATCH] Add Broadcom PHY support
> 
> This patch adds a driver to support the bcm5421s and bcm5461s PHY
> 
> Kernel version:  linux-2.6.18-rc6
> 
> Signed-off-by: Amy Fong 

Some 5421's need special initialisation (see drivers/net/sungem_phy.c),
might be worth having them there too. I was also wondering... for
spidernet, we need to enable the fiber mode on the PHY. Does phylib has
an API for that ?

I'd like to look into moving sungem and spidernet over to phylib.

Ben.


