From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Wed, 05 Nov 2008 01:55:52 -0800 (PST)
Message-ID: <20081105.015552.33573006.davem@davemloft.net>
References: <20081103010431.GA29905@gondor.apana.org.au>
	<20081105.013148.156667310.davem@davemloft.net>
	<20081105095428.GA4584@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60470
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754445AbYKEJ4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:56:17 -0500
In-Reply-To: <20081105095428.GA4584@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 5 Nov 2008 12:54:28 +0300

> It was ENOENT from crypto_alg_mod_lookup(), actually.
> 
> I think liberal printk additions are the way to go.

Saying "type dmesg" to figure out why an IPSEC configuration fails
is not very user friendly, even for application developers.

About the rmmod thing, we can do something similar to how
we handle nesting of irq_regs().  Ie. there are things that
push and pop the stack of ->error_desc.  rmmod operations
could be one of those things

