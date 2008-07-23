From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: The proper way of delaying tx in a driver
Date: Wed, 23 Jul 2008 18:19:09 +1000
Message-ID: <1216801149.11027.313.camel@pasglop>
References: <1216795043.11027.311.camel@pasglop>
	 <20080723.011134.256015233.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60956 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbYGWITO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 04:19:14 -0400
In-Reply-To: <20080723.011134.256015233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-23 at 01:11 -0700, David Miller wrote:

 .../...

> At least for non-LLTX driver.  For LLTX ones, oh well, too bad, they
> have to find their own ways to ensure such things.  It's deprecated
> for a reason :)

Thanks. I'm happy to remove LLTX from sungem (in fact, I started doing
it when stumbled upon the problem of how the heck do I freeze my tx
queue ?).

Cheers,
Ben.


