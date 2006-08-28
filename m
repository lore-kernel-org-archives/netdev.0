From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/*: use SLAB_PANIC
Date: Mon, 28 Aug 2006 13:36:37 -0700 (PDT)
Message-ID: <20060828.133637.107685776.davem@davemloft.net>
References: <20060826230841.GA5204@martell.zuzino.mipt.ru>
	<20060828093651.GA31341@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44472
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751487AbWH1Ugc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:36:32 -0400
To: hch@infradead.org
In-Reply-To: <20060828093651.GA31341@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 28 Aug 2006 10:36:51 +0100

> ipv6 can be modular, so panicing on a initialization failure is wrong.

That may be the case, but he merely translated the code
as it existed, he didn't change it to start panic()'ing
it already did.

It would be a seperate change to undo the panic() in
the ipv6 code.
