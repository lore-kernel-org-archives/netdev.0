From: Patrick McHardy <kaber@trash.net>
Subject: Re: [0/4] gre: Ethernet over GRE
Date: Thu, 09 Oct 2008 14:12:44 +0200
Message-ID: <48EDF53C.9020700@trash.net>
References: <20081009070424.GA16684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49224 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbYJIMMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 08:12:47 -0400
In-Reply-To: <20081009070424.GA16684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> This series of patches add Ethernet over GRE support.  The user
> space interface is done with the rtnl_link mechanism.  I'll post
> the patches for iproute too.
> 
> There has been a small demand of such a tunneling mechanism that
> allows direct Ethernet connections over IP.  In the past many
> efforts have been made in this direction.  However, inadequacies
> with our user interface have foiled many of them.
> 
> Recently Patrick McHardy created the rtnl_link mechanism which
> finally allows tunnel configuration to be brought into the 21st
> century.  Having tried it I must say that it has been an absolute
> pleasure to use :)

Glad you like it :)

> This should be completely backwards compatible in that if you
> don't create Ethernet over GRE tunnels then your GRE experience
> should not differ one single bit from before.  However, you can
> manage your existing GRE interfaces using the new interface should
> you choose to do so.

These patches look good to me, thanks for doing this work.
