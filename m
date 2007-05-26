From: Horms <horms@verge.net.au>
Subject: Re: [ipvs] BUG: soft lockup detected on CPU#3!
Date: Sat, 26 May 2007 11:22:40 +0900
Message-ID: <20070526022239.GD4169@verge.net.au>
References: <446f47c20705221019j34de745fj9aad8633a6edfd54@mail.gmail.com> <20070525084645.GA14817@verge.net.au> <446f47c20705250230n6d43b6eu4b163a170fdc6007@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, ja@ssi.bg, nedev <netdev@vger.kernel.org>
To: Sebastien Estienne <sebastien.estienne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:33260 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbXEZCWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 22:22:43 -0400
Content-Disposition: inline
In-Reply-To: <446f47c20705250230n6d43b6eu4b163a170fdc6007@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 25, 2007 at 09:30:52AM +0000, Sebastien Estienne wrote:
> 
> I didn't try 2.6.21 yet, but using ubuntu dapper kernel (2.6.15) i
> can't reproduce the bug.
> When i was using feisty kernel (2.6.20), i can reproduce in less than 5 
> minutes.
> 
> I'm using lvs to loadbalance some mysql servers, i wrote a deamon that
> check the synchro of the mysql replication on each slave and adjust
> the wieght on the lvs every 500ms

It does look a lot like there is some sort of locking problem in there.
Would it be possible to send your kernel config, as the locking
deatails to change a little with different configs.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

