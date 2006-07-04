From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm6: move define/ifdef check order
Date: Mon, 03 Jul 2006 19:46:55 -0700 (PDT)
Message-ID: <20060703.194655.38711929.davem@davemloft.net>
References: <20060702143611.dffe7b15.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54205
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751385AbWGDCqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:46:39 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060702143611.dffe7b15.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Sun, 2 Jul 2006 14:36:11 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> The first check for #ifdef XFRM6_TUNNEL_SPI_MAGIC needs to come after
> the optional #define of it, otherwise the variable won't be there
> for the rest of the code to use.
> 
> Shouldn't that CONFIG_IPV6_XFRM6_TUNNEL_DEBUG be part of Kconfig
> or have its name changed?
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Yes, indeed.  Nothing named CONFIG_* should be defined explicitly
by the source files, only through Kconfig.

I would rather address that than apply this patch.

Thanks Randy.
