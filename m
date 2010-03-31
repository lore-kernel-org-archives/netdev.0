From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 13:54:27 -0700 (PDT)
Message-ID: <20100331.135427.149457693.davem@davemloft.net>
References: <1270042795.26743.31.camel@bigi>
	<1270042883.26743.32.camel@bigi>
	<20100331135629.GD14082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41126
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141Ab0CaUyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:54:25 -0400
In-Reply-To: <20100331135629.GD14082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 Mar 2010 21:56:29 +0800

> This is inconsistent with the behaviour of SADB flushes, and the
> spirit of RFC2367.

Want to have an even larger list of areas where we're not compliant
with that RFC2367 that everyone has to extend and makes changes to in
order to be useful? :-)

Herbert, you have to show that something breaks because of this,
because the new behavior helps in diagnosis and efficiency and the old
behavior has been a serious pet peeve of mine just as it was for
Jamal.
