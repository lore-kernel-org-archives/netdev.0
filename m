From: David Miller <davem@davemloft.net>
Subject: Re: v2 [Patch 1/1] [BUG-FIX] udplite: Avoid u16 checksum coverage
 wrap-around
Date: Mon, 21 Jul 2008 13:35:37 -0700 (PDT)
Message-ID: <20080721.133537.36663011.davem@davemloft.net>
References: <20080630115427.GA8416@gerrit.erg.abdn.ac.uk>
	<20080721100409.GA13198@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbYGUUfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:35:37 -0400
In-Reply-To: <20080721100409.GA13198@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 21 Jul 2008 11:04:09 +0100

> udplite: Protection against coverage value wrap-around
> 
> This patch clamps the cscov setsockopt values to a maximum of 0xFFFF.
> 
> Setsockopt values greater than 0xffff can cause an unwanted wrap-around.
> Further, IPv6 jumbograms are not supported (RFC 3838, 3.5), so that values
> greater than 0xffff are not even useful.
> 
> Further changes: fixed a typo in the documentation.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.

I'll queue this up for -stable too.
