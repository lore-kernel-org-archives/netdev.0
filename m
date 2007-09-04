From: Thomas Graf <tgraf@suug.ch>
Subject: Re: some weird corruption in net-2.6.24
Date: Tue, 4 Sep 2007 13:24:50 +0200
Message-ID: <20070904112450.GQ18480@postel.suug.ch>
References: <20070903095719.GE18480@postel.suug.ch> <E1ISKzA-0007xM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37994 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbXIDLYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 07:24:30 -0400
Content-Disposition: inline
In-Reply-To: <E1ISKzA-0007xM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2007-09-04 07:05
> Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > I've been trying to reproduce this, what happens on my system
> > is that when the ISAKMP SA lifetime is exceeded the rekeying
> > fails and my connection dies. I can reproduce this back to
> > 2.6.22 and it doesn't seem related to my recent xfrm_user work.
> > It looks like this behaviour is hiding the bug you are seeing.
> 
> Could you try extending the ISAKMP SA life time so that it is
> longer than the IPSec SA life time?

Yes, in this case the IPSec SA rekeying works just fine.
I can't spot any signs of corruptions or alike.
