From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 2/7] 8139cp : removal of headers.
Date: Fri, 30 Sep 2011 14:13:40 -0400 (EDT)
Message-ID: <20110930.141340.698884892100746534.davem@davemloft.net>
References: <20110930103719.GC26727@electric-eye.fr.zoreil.com>
	<1317391428.4068.36.camel@deadeye>
	<20110930162649.GA32195@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab1I3SOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 14:14:46 -0400
In-Reply-To: <20110930162649.GA32195@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 30 Sep 2011 18:26:49 +0200

> I am sceptical about the value in including so much headers for
> rather common things at the network device driver level. After all
> the code is supposed to be cross-platform, modular or monolithic
> built.

We are trying very hard to split out the implicit inclusions of
one set of headers into another.

So you absolutely should always include the headers for all features
you explicitly use.
