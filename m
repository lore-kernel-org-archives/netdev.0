From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Spidernet - remove ETH_ZLEN check in earlier patch
Date: Fri, 10 Nov 2006 09:58:02 -0800
Message-ID: <20061110095802.26854fea@freekitty>
References: <1163181046.4422.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>, Work <jklewis@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59562 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161926AbWKJSH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 13:07:29 -0500
To: jim@jklewis.com
In-Reply-To: <1163181046.4422.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 11:50:46 -0600
Jim Lewis <jim@jklewis.com> wrote:

> Subject: Spidernet - remove ETH_ZLEN check in earlier patch
> From: James K Lewis <jklewis@us.ibm.com>
> 
> In an earlier patch, code was added to pad packets that were less that
> ETH_ZLEN (60) bytes using the skb_pad function. This has caused hangs
> when accessing certain NFS mounted file systems. This patch removes the
> check and solves the NFS problem. The driver, with this patch, has been
> tested extensively. Please apply.
> 
> 
> Signed-off-by: James K Lewis <jklewis@us.ibm.com>

Does the hardware do padding for you? The padding is important for the Ethernet
spec, and for security reasons (random memory leakage).

-- 
Stephen Hemminger <shemminger@osdl.org>
