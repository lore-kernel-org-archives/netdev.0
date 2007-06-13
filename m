From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: remove initial_ssthresh from Cubic
Date: Wed, 13 Jun 2007 11:26:52 -0700 (PDT)
Message-ID: <20070613.112652.112623832.davem@davemloft.net>
References: <20070612233814.4b04db2f.billfink@mindspring.com>
	<20070613.005642.85685043.davem@davemloft.net>
	<20070613102718.61d67a36@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, sangtae.ha@gmail.com, rhee@eos.ncsu.edu,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760149AbXFMS0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:26:37 -0400
In-Reply-To: <20070613102718.61d67a36@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 13 Jun 2007 10:27:18 -0700

Please make patches against my net-2.6 tree, I already
made changes in this area.

> Remove the initial slow start override from TCP cubic.
> The old code caused Cubic to start out in slow start mode, which
> is less agressive but caused slow performance.
> 
> The administrator can override initial slow start threshold on any
> TCP congestion control method via the TCP route metrics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

I already sent a merge request to Linus that just changed
the default to zero.

No need to remove it for now so people can still play
with it if they want to, that's harmless.

You missed BIC too, which I did take care of...
