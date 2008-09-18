From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: do not enable peer features if we can't do
 them.
Date: Thu, 18 Sep 2008 16:29:41 -0700 (PDT)
Message-ID: <20080918.162941.157950819.davem@davemloft.net>
References: <1221773464-28845-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbYIRX3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:29:53 -0400
In-Reply-To: <1221773464-28845-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 18 Sep 2008 17:31:03 -0400

> Do not enable peer features like addip and auth, if they
> are administratively disabled localy.  If the peer resports
> that he supports something that we don't, neither end can
> use it so enabling it is pointless.  This solves a problem
> when talking to a peer that has auth and addip enabled while
> we do not.  Found by Andrei Pelinescu-Onciul <andrei@iptel.org>.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

I applied this, but it is at best borderline for outside the
merge window.  It doesn't fix an OOPS nor a security issue nor
an entry in the 2.6.x regression list, therefore strictly speaking
this fix is not appropriate at this time.

Please apply this criteria when deciding whether to submit future
fixes for net-2.6 inclusion.
