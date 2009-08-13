From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] inet6: resolve IPV6_TCLASS conversion problems
Date: Thu, 13 Aug 2009 16:28:48 -0700 (PDT)
Message-ID: <20090813.162848.11283179.davem@davemloft.net>
References: <resolve_IPV6_TCLASS>
	<1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56580
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756487AbZHMX2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:28:38 -0400
In-Reply-To: <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun,  9 Aug 2009 20:12:47 +0200

> These are two patches dealing with the IPV6_TCLASS sticky socket option. They
> belong together, the second patch is a follow-up and fixes the remainder.
> 
> Patch #1: Removes unnecessary conversions (tclass being u8)
>           This is a resent, an OK was given in the reply of 
>           http://marc.info/?l=linux-netdev&m=124820628409987&w=2
> Patch #2: Solves the remaining problem of passing the socket option,
>           fixing a bug (-1 became a non-default traffic class of 0xff).

Both applied to net-next-2.6
