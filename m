From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 21:49:15 -0700 (PDT)
Message-ID: <20080706.214915.255106355.davem@davemloft.net>
References: <487176A2.6080604@cn.fujitsu.com>
	<20080706.205905.159207367.davem@davemloft.net>
	<20080706213427.406e8f29@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbYGGEtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 00:49:16 -0400
In-Reply-To: <20080706213427.406e8f29@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 6 Jul 2008 21:34:27 -0700

> On Sun, 06 Jul 2008 20:59:05 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > 
> > Also correct.
> 
> ok updated version below; I also added an explicit comment for the
> ethtool locking
> 
> From: Arjan van de Ven <arjan@linux.intel.com>
> Subject: Use WARN_ONCE() in the netdev timeout handler (and print module name)

I'm basically fine with these changes.

But plain WARN() and WARN_ONCE() are not in any tree I am maintaining
at the moment, so I really can't add it to net-next-2.6 or net-2.6
even if I wanted to.

Do you really need this dependency?
