From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Fri, 10 Aug 2007 15:06:25 -0700 (PDT)
Message-ID: <20070810.150625.105430969.davem@davemloft.net>
References: <46BCCE8B.2050605@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42607
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932089AbXHJWGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:06:25 -0400
In-Reply-To: <46BCCE8B.2050605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 10 Aug 2007 16:46:03 -0400

> This patch introduces autotuning to the sctp buffer management code
> similar to the TCP.  The buffer space can be grown if the advertised
> receive window still has room.  This might happen if small message
> sizes are used, which is common in telecom environmens.
> New tunables are introduced that provide limits to buffer growth
> and memory pressure is entered if to much buffer spaces is used.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks Vlad.

Can you in the future fix up whitespace issues like this:

Adds trailing whitespace.
diff:21: 
Space in indent is followed by a tab.
diff:27: 	int amt;
Space in indent is followed by a tab.
diff:48: 		amt = asoc->base.sk->sk_sndbuf - amt;
Space in indent is followed by a tab.
diff:55:  	return amt;

I know where the "Space in indent" cases come from, you apply the
patch to merge it into a current tree, you get rejects, then you edit
in the foo.rej hunks by hand into the code but forget to remove the
extra leading whitespace characters.

:-)
