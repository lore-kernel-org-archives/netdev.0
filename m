From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/23] TIPC: Updates for what will be v3.3
Date: Tue, 27 Dec 2011 13:08:07 -0500 (EST)
Message-ID: <20111227.130807.1680254459456306555.davem@davemloft.net>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662Ab1L0SIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:08:09 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 27 Dec 2011 12:39:19 -0500

> Here are some more updates for TIPC, based on the backlog of stuff
> that was unfortunately stacked away in sourceforge a while ago.
> 
> Given the timing, please feel free to defer these to the for-3.4
> net-next if there isn't a convenient opportunity to process it
> before 3.2 is officially released.  I can easily resend later.
> 
> Fortunately, the SF backlog will finally be 100% gone with the
> pending stuff that will be sent in the next year for the 3.4
> net-next, so that will be nice to have that task closed out.
> 
> I just finished testing this over the wire between an x86-32 and
> an x86-64 box, with both taking turns being server and client.

Pulled, thanks Paul.

Two suggestions:

1) Please rename things like "struct media" to something more global
   namespace friendly like "struct tipc_media"

2) We really should get rid of the ad-hoc debug logging facility tipc
   uses.  It's not like there aren't tons of generic, well maintained,
   feature-full logging facilities available.  There is no reason for
   tipc to have it's own special, private, logginc facility.

   If the generic facilities lack some feature, add it and submit
   it for inclusion to linux-kernel so everyone can use it, not just
   TIPC.
