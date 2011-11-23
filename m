From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 18:53:12 -0500 (EST)
Message-ID: <20111123.185312.934208167596513736.davem@davemloft.net>
References: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
	<20111123083712.69a2ac6e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab1KWXxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 18:53:16 -0500
In-Reply-To: <20111123083712.69a2ac6e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Nov 2011 08:37:12 -0800

> 1. Since linux/dql.h is only kernel components (not API), it should
>    be net/dql.h

It's a library routine under lib/, meant to be available to anyone not
just networking components even though networking is the only current
consumer.

His placement of the header file is therefore correct as-is.
