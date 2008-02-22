From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RTNL]: Validate hardware and broadcast address attribute for RTM_NEWLINK
Date: Fri, 22 Feb 2008 14:31:35 +0100
Message-ID: <20080222133135.GC20815@postel.suug.ch>
References: <20080222125702.GB20815@postel.suug.ch> <47BEC89E.9030909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48498 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760246AbYBVNbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 08:31:15 -0500
Content-Disposition: inline
In-Reply-To: <47BEC89E.9030909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-02-22 14:05
> Minor nitpick: it would be more logical to put this in the
> 
> if (dev) {
>  ...
> 
> branch a bit below since thats the only path that leads to
> do_setlink(). That would also allow to remove the
> if (dev) check from validate_linkmsg().

I knew this question would come up :-)

The reason I did it this way is to keep validate_linkmsg() generic
and make it possible to put validation code which must also apply
to new links (dev==NULL) into that function.
