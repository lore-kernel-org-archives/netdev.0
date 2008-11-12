From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 14:26:25 -0800 (PST)
Message-ID: <20081112.142625.120012106.davem@davemloft.net>
References: <1226494493.3016.3.camel@achroite>
	<20081112.134618.30673281.davem@davemloft.net>
	<1226526657.3016.10.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752208AbYKLW0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:26:25 -0500
In-Reply-To: <1226526657.3016.10.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Nov 2008 21:50:57 +0000

> See <http://c-faq.com/expr/seqpoints.html> if you're not convinced.

I don't think that has any implications for the piece of
code we are talking about.

Just google "C order of evaluation" and you will get hundreds
of tables, and all of them will have an entry for "|" (not
just "||") which says that operands are evaluated left to
right.

And since these MMIO reads are volatile operations, there is
no way the compiler can execute them out of order.

And the plain truth is that no compiler does, and that is what
matters in the end.
