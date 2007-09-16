From: David Miller <davem@davemloft.net>
Subject: Re: [v3 PATCH 0/2] Add RCU locking to SCTPaddress management
Date: Sun, 16 Sep 2007 16:01:02 -0700 (PDT)
Message-ID: <20070916.160102.54198849.davem@davemloft.net>
References: <11897120771278-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp@hp.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:40327
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751998AbXIPXBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:01:04 -0400
In-Reply-To: <11897120771278-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 13 Sep 2007 15:34:35 -0400

> Thanks to Sridhar Samudral and Paul McKenney for all the help and comments.
> I think this is a final version, unless someone else can spot more problems.
> I've ran this under heavy load and it the patches behaves well.
> 
> I think patch 1 is a candidate for 2.6.23 since it fixes a bug, but splitting
> these seems a bit odd to me.  I'll leave it to DaveM to decide where to
> put them.

Since you tested this well, I've decided to put both of these
patches into net-2.6

I agree it's stupid to split them up.

There'll be some merge hassles when I rebase net-2.6.24, but
that tree is such a monster that this is inevitable for every
bug fix I queue up for 2.6.23 :-)

