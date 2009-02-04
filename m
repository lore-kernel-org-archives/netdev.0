From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 03 Feb 2009 16:46:09 -0800 (PST)
Message-ID: <20090203.164609.160183741.davem@davemloft.net>
References: <20090202.235017.253437221.davem@davemloft.net>
	<20090203094108.GA4639@ff.dom.local>
	<20090203111012.GA16878@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbZBDAqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 19:46:13 -0500
In-Reply-To: <20090203111012.GA16878@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Tue, 3 Feb 2009 14:10:12 +0300

> NTA tried to solve this by not allowing to free the data allocated on
> the different CPU, contrary to what SLAB does. Modulo cache coherency
> improvements,

This could kill performance on NUMA systems if we are not careful.

If we ever consider NTA seriously, these issues would need to
be performance tested.
