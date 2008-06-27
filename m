From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-06-25
Date: Fri, 27 Jun 2008 04:28:18 -0700 (PDT)
Message-ID: <20080627.042818.76860067.davem@davemloft.net>
References: <20080625153624.GB9111@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbYF0L2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 07:28:18 -0400
In-Reply-To: <20080625153624.GB9111@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 25 Jun 2008 11:36:24 -0400

> Here is the latest round of wireless fixes for 2.6.26.
> 
> The EU regulatory domain patch is straight-forward and should not
> affect anyone who doesn't choose to use it.  It is already queued in
> net-next-2.6, but upon reflection I think it makes sense to include
> it as a fix.  I don't think git will choke on it at all.
> 
> The iwlwifi patch is physically bigger than I would like to see at this
> point of the release, but it is isolated to the iwlwifi drivers and
> it should avoid problems with some cards trying to scan on channels
> they don't actually support.
> 
> The rt2x00 patch seems a bit bigger than it really is, as it moves
> and consolidates some existing code.
> 
> The b43 and b43legacy are all basically straight-forward bugfixes.

Pulled and pushed back out to net-2.6, thanks!

I'll deal with the net-next-2.6 merge stuff after some sleep.
