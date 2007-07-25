From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 22:12:22 -0700 (PDT)
Message-ID: <20070724.221222.116353582.davem@davemloft.net>
References: <1185330794.1803.452.camel@localhost.localdomain>
	<20070724.212951.70218044.davem@davemloft.net>
	<1185340196.1803.482.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751822AbXGYFMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 01:12:23 -0400
In-Reply-To: <1185340196.1803.482.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 25 Jul 2007 15:09:55 +1000

> Not pretty 8(

Not at all and cmpxchg() isn't really a generically usable
primitive.  Yes all platforms provide atomic_cmpxchg() in
one form or another, but it's really barbaric and inefficient
on some cpu types.

Let's can this idea for now.
