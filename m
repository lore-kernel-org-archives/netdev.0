From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 09:42:16 +0000
Message-ID: <20090114094215.GC4234@ff.dom.local>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, dada1@cosmosbay.com,
	w@1wt.eu, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:44391 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbZANJmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 04:42:23 -0500
Content-Disposition: inline
In-Reply-To: <20090114.012919.117682429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 01:29:19AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 14 Jan 2009 08:53:08 +0000
> 
> > Actually, I still think my second approach (the PageSlab) is probably
> > (if tested) the easiest for now, because it should fix the reported
> > (Willy's) problem, without any change or copy overhead for splice to
> > file (which could be still wrong, but not obviously wrong).
> 
> It's a simple fix, but as Herbert stated it leaves other ->sendpage()
> implementations exposed to data corruption when the from side of the
> pipe buffer is a socket.

I don't think Herbert meant other ->sendpage() implementations, but I
could miss something.

> That, to me, is almost worse than a bad fix.
> 
> It's definitely worse than a slower but full fix, which the copy
> patch is.

Sorry, I can't see how this patch could make sendpage worse.

Jarek P.
