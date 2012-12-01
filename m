From: Willy Tarreau <w@1wt.eu>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Sat, 1 Dec 2012 23:40:44 +0100
Message-ID: <20121201224044.GL25450@1wt.eu>
References: <20121115222812.GA647@1wt.eu> <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu> <20121201205227.GA28390@1wt.eu> <1354398458.20109.528.camel@edumazet-glaptop> <1354401121.20109.531.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:36373 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab2LAWkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 17:40:49 -0500
Content-Disposition: inline
In-Reply-To: <1354401121.20109.531.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2012 at 02:32:01PM -0800, Eric Dumazet wrote:
> On Sat, 2012-12-01 at 13:47 -0800, Eric Dumazet wrote:
> 
> > Thanks a lot Willy
> > 
> > I believe do_tcp_sendpages() needs a fix, I'll send a patch asap 
> > 
> 
> Could you try the following patch ?
> 
> do_tcp_sendpages() looks really wrong, as only one page is provided by
> the caller.

Excellent Eric, it's rock solid now both with the reproducer and with
haproxy!  Feel free to add my Tested-By if you want.

I really think we should feed this to Linus quickly before he releases 3.7,
as I'm realizing that it would really not be nice to have a user-triggerable
crash in a release :-/

Thanks !
Willy
