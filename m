From: David Miller <davem@davemloft.net>
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
 Auto-load (when supported) CCID plugins for negotiation
Date: Thu, 18 Dec 2008 19:15:34 -0800 (PST)
Message-ID: <20081218.191534.194793981.davem@davemloft.net>
References: <20081217214608.GC14518@ghostprotocols.net>
	<20081217.212151.230224281.davem@davemloft.net>
	<20081218053349.GA6172@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbYLSDPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:15:32 -0500
In-Reply-To: <20081218053349.GA6172@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Dec 2008 06:33:49 +0100

> | > Build CCID2, because the RFC requires it to be always available, and
> | > CCID3 too as it is the most interesting one for VoIP, etc, together with
> | > the main, layer 3 agnostic, DCCP core code, so that we have a faster
> | > connection path by eliminating the need to always go thru the CCID
> | > registration lock. But keep it there, so that we can experiment with
> | > newer CCIDs without having to rebuild/reboot the whole kernel.
> | > 
> | > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> | 
> | Gerrit, are you OK with this?
> | 
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks everyone.
