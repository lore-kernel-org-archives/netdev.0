From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH resend] rewrite AF_UNIX garbage collector, fixes race
Date: Wed, 11 Jul 2007 08:41:30 +0200
Message-ID: <E1I8VtC-0007uM-00@dorka.pomaz.szeredi.hu>
References: <E1I61UT-0006Gk-00@dorka.pomaz.szeredi.hu>
	<20070710.221224.48800386.davem@davemloft.net> <20070710222511.bcc87825.akpm@linux-foundation.org>
Cc: davem@davemloft.net, miklos@szeredi.hu, netdev@vger.kernel.org,
	ebiederm@xmission.com, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:50896 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbXGKGlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 02:41:55 -0400
In-reply-to: <20070710222511.bcc87825.akpm@linux-foundation.org> (message from
	Andrew Morton on Tue, 10 Jul 2007 22:25:11 -0700)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > But myself, nor any other developers, are going to review your work
> > any faster if you do things like try to slip things in behind the
> > maintainer's back as you attempted to do yesterday by asking Andrew to
> > put your AF_UNIX garbage collector rewrite directly into his -mm tree.
> 
> mmm...  I didn't see it as a slip-behind-the-back thing.  More a "park it
> in -mm for a bit of concurrent testing and so it doesn't get lost and so I
> don't have to worry about it any more" thing.  Plenty of that goes on.

Exactly.  I have CC-ed everyone involved, and clearly stated that I do
want it reviewed.  There wasn't any evil intention.

I _am_ slightly pissed off by still not having this bug fixed after
two months, and after spending considerable effort at hunting it down
and finding a solution for it (actually three different solutions by
now).

This may seem low priority and irrelevant, but it _is_ a bug, and it's
affecting a real world application.  So please take that into
consideration.

Thanks,
Miklos
