From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 15:40:34 +0300
Message-ID: <20090107124034.GB31255@ioremap.net>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:50761 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbZAGMkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 07:40:35 -0500
Content-Disposition: inline
In-Reply-To: <20090107123504.GN32491@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 01:35:04PM +0100, Jens Axboe (jens.axboe@oracle.com) wrote:
> Irregardless of that particular oddity, I don't think this is the right
> path to take at all. We need to delay the pipe buffer consumption until
> the appropriate time.

As a proof of concept we can put a delayed work_struct into the buffer
and only release its content after some timeout big enough (like one
second or so) for the hardware to actually transmit its buffers.

-- 
	Evgeniy Polyakov
