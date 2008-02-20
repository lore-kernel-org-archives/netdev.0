From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Wed, 20 Feb 2008 15:07:53 -0800 (PST)
Message-ID: <20080220.150753.17432290.davem@davemloft.net>
References: <20080220212302.GJ30160@fieldses.org>
	<20080220.134257.41491836.davem@davemloft.net>
	<20080220224053.GA8500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bfields@fieldses.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755811AbYBTXHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:07:17 -0500
In-Reply-To: <20080220224053.GA8500@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 20 Feb 2008 23:40:53 +0100

> David Miller <davem@davemloft.net> :
> [...]
> > Because it forces me to pull Linus's upstream into net-2.6,
> > I don't have any choice in the matter.
> 
> Jeff's choice is a bit surprizing. That being said, it would had been nice
> to fast-forward net-2.6 from a442585952f137bd4cdb1f2f3166e4157d383b82
> to Linus's upstream before applying the content of
> 12aa343add3eced38a44bdb612b35fdf634d918c in order to keep the drift
> with Linus's branch to a minimum during the bugfix cycle.

Keep in mind there are also pending fixes in my net-2.6 tree which
Linus hasn't pulled in yet as well.

I watch Linus's tree closely, and I'll see any potential merge issue
long before it matters, and I always double check before pushing
stuff out to him.

My job as tree master is to deal with all the merge hassles, should
they occur.  But up until now everything networking has gone through
my tree and everything is fine.

The net-2.6 tree isn't even a week old.  I planned to pull Linus's
tree in right before I leave for a short trip tomorrow afternoon.
I'm really not being allowed to make that choice by how these
changes are being merged to me.

Heck, Jeff even thanked me for making my net-2.6 tree stable and not
rebasing, so his method of merging this stuff is doubly surprising for
me.

Jeff, I really don't want to pull that tree in.  Please trust me as
your upstream to handle merging issues, as needed.

Thanks!
