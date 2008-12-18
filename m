From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
	Auto-load (when supported) CCID plugins for negotiation
Date: Thu, 18 Dec 2008 06:33:49 +0100
Message-ID: <20081218053349.GA6172@gerrit.erg.abdn.ac.uk>
References: <20081217214608.GC14518@ghostprotocols.net> <20081217.212151.230224281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63875 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750778AbYLRFeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 00:34:04 -0500
Content-Disposition: inline
In-Reply-To: <20081217.212151.230224281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > Build CCID2, because the RFC requires it to be always available, and
| > CCID3 too as it is the most interesting one for VoIP, etc, together with
| > the main, layer 3 agnostic, DCCP core code, so that we have a faster
| > connection path by eliminating the need to always go thru the CCID
| > registration lock. But keep it there, so that we can experiment with
| > newer CCIDs without having to rebuild/reboot the whole kernel.
| > 
| > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
| 
| Gerrit, are you OK with this?
| 
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Yes absolutely and thanks a lot to Arnaldo for the quick reply.

I apologize being late in replying, I actually sat down after work
yesterday and formulated a reply which is in agreement with this code.
