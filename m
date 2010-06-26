From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] dccp: fix slow slow-start by symmetric Syn-RTT
Date: Fri, 25 Jun 2010 21:36:43 -0700 (PDT)
Message-ID: <20100625.213643.212386410.davem@davemloft.net>
References: <ccid3_4_tfrc_slow_slow_start_issue>
	<1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751064Ab0FZEgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:36:31 -0400
In-Reply-To: <1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Jun 2010 13:14:33 +0200

> This changeset fixes slow startup behaviour for DCCP streaming via
> CCID-3/4 when a listening server needs to start streaming.
> 
> Patch #1: removes an unused 'sk' argument from several functions,
>           it is used by patch #2;
> 
> Patch #2: fixes the sluggish slow-start problem by taking an RTT
>           sample from the initial handshake also for listeing servers.

Both applied to net-next-2.6, thanks!
