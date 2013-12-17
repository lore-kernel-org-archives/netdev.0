From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 0/3] IPComp fixes
Date: Tue, 17 Dec 2013 12:37:58 +0100
Message-ID: <20131217113758.GK31491@secunet.com>
References: <1387190870-32506-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60691 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3LQLiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 06:38:01 -0500
Content-Disposition: inline
In-Reply-To: <1387190870-32506-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 06:47:47PM +0800, Fan Du wrote:
> Hi,
> 
> This patchset includes bug fix focusing on IPComp mainly, which addresses
> IPComp Compression Parameter Index(CPI, 16bits of 32bits SPI value) problem.
> 
> And other issue is the compression part, undesirable packet will not be
> compressed, and then send into wire, this packet will be dropped by policy
> checking in the receiver side.
> 
> v2:
>   Patch1: Clean up align issue from v1.
>   Patch2: Introduce verify_userspi_info for pkfey and netlink interface
>           to share code.
>   Patch3: Add Documentation/networking/ipsec.txt to document known issues. 
> 
> v3:
>   Patch2: Fix while space error.
>   Patch3: Del empty line
> 
> Fan Du (3):
>   xfrm: check user specified spi for IPComp
>   xfrm: export verify_userspi_info for pkfey and netlink interface
>   xfrm: Add file to document IPsec corner case
> 

All applied to ipsec-next, thanks Fan!
