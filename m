From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Sun, 25 Jan 2009 21:22:03 -0800 (PST)
Message-ID: <20090125.212203.15909648.davem@davemloft.net>
References: <20090120110144.GB17004@ff.dom.local>
	<20090120.091616.224452074.davem@davemloft.net>
	<20090122090442.GB11139@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750714AbZAZFWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 00:22:01 -0500
In-Reply-To: <20090122090442.GB11139@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 22 Jan 2009 09:04:42 +0000

> It seems this sk_sndmsg_page usage (refcounting) isn't consistent.
> I used here tcp_sndmsg() way, but I think I'll go back to this question
> soon.

Indeed, it is something to look into, as well as locking.

I'll try to find some time for this, thanks Jarek.
