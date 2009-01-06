From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 10:01:13 +0000
Message-ID: <20090106100112.GB9513@ff.dom.local>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:50046 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbZAFKBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 05:01:19 -0500
Content-Disposition: inline
In-Reply-To: <20090106094138.GE25644@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 10:41:38AM +0100, Willy Tarreau wrote:
...
> > Great story! Alas I don't understand this fully either, but it seems
> > Changli Gao was concerned with sendpage sending this "as pages", so
> > when NETIF_F_SG flag is available. Did you try this without SG btw?
> 
> No I did not. I can try, it's not too hard. It would in part defeat the
> purpose of the mechanism (especially at 10 Gbps) but at least it will
> help narrow the problem down.

Yes, I meant it only as a proof of concept. BTW, delaying TCP acks a
bit for these sendpages should then make it more reproducible, I guess.

Jarek P.
