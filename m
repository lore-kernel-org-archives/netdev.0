From: David Miller <davem@davemloft.net>
Subject: Re: [INET]: sk_reuse is valbool
Date: Sun, 13 Apr 2008 21:49:37 -0700 (PDT)
Message-ID: <20080413.214937.89523817.davem@davemloft.net>
References: <20080407150133.GB16869@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757954AbYDNEtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:49:35 -0400
In-Reply-To: <20080407150133.GB16869@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 7 Apr 2008 16:01:33 +0100

> I found this while checking how DCCP handles duplicate bind operations;
> it seems it is a remainder of earlier code and now defunct.
> 
> -----------------------------------> Patch <---------------------------------------
> [INET]: sk_reuse is valbool
> 
> sk_reuse is declared as "unsigned char", but is set as type valbool in net/core/sock.c.
> There is no other place in net/ where sk->sk_reuse is set to a value > 1, so the test 
> "sk_reuse > 1" can not be true.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I'll apply this to net-2.6.26, thanks Gerrit.

I wonder what the history is of this thing.  Perhaps it was used
for an implementation of SO_REUSEPORT, or something like that,
which got removed.
