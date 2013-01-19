From: Eric Wong <normalperson@yhbt.net>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Sat, 19 Jan 2013 07:15:47 +0000
Message-ID: <20130119071547.GA3478@dcvr.yhbt.net>
References: <20130119044957.GA25395@dcvr.yhbt.net>
 <1358574847.3464.422.camel@edumazet-glaptop>
 <1358575996.3464.447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:48030 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab3ASHPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 02:15:48 -0500
Content-Disposition: inline
In-Reply-To: <1358575996.3464.447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:
> > Hmm, this might be already fixed in net-next tree, could you try it ?
> 
> Yes, running your program on net-next seems OK.
> 
> David, we need the two following commits.

> commit 9ca1b22d6d228177e6f929f6818a1cd3d5e30c4a
> commit 18aafc622abf492809723d9c5a3c5dcea287169e

Thanks Eric!  I cherry picked both of these on top on 3.7.3
and everything is great \o/
