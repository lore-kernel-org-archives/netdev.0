From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2/2] [BRIDGE]: Add support for NETIF_F_HW_CSUM devices
Date: Thu, 15 Jun 2006 13:55:36 -0700
Message-ID: <20060615135536.2a20058d@dxpl.pdx.osdl.net>
References: <20060613112511.GA13204@gondor.apana.org.au>
	<20060613112543.GA13253@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9709 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031358AbWFOU7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 16:59:05 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060613112543.GA13253@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jun 2006 21:25:43 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi:
> 
> [BRIDGE]: Add support for NETIF_F_HW_CSUM devices
> 
> As it is the bridge will only ever declare NETIF_F_IP_CSUM even if all
> its constituent devices support NETIF_F_HW_CSUM.  This patch fixes this
> by supporting the first one out of NETIF_F_NO_CSUM, NETIF_F_HW_CSUM,
> and NETIF_F_IP_CSUM that is supported by all constituent devices.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,

Looks fine.
