From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Configurable tap interface MTU
Date: Sun, 16 Sep 2007 12:22:17 -0700 (PDT)
Message-ID: <20070916.122217.68050499.davem@davemloft.net>
References: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
	<E1IVIv8-0003Uc-00@gondolin.me.apana.org.au>
	<e6c711510709120954i29a8f86bg9ea7bb337a039b5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	maxk@qualcomm.com, linux-kernel@vger.kernel.org
To: eswierk@arastra.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54352
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751027AbXIPTWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 15:22:44 -0400
In-Reply-To: <e6c711510709120954i29a8f86bg9ea7bb337a039b5a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ed Swierk" <eswierk@arastra.com>
Date: Wed, 12 Sep 2007 09:54:35 -0700

> On 9/11/07, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > Please make it 65535 without an Ethernet header and 65521
> > with an Ethernet header.
> 
> Here is a revised patch that allows MTUs up to 65535 for tap
> interfaces and up to 65521 for tun interfaces.
> 
> (If I set the MTU to 65521 on a tun interface, ping complains "message
> too long" when I send a 65521-byte packet; 65520 works okay, though.)

Applied to net-2.6.24

Please provide a proper Signed-off-by: line and a full
changelog with every patch submission and revision in
the future.

Thanks.

