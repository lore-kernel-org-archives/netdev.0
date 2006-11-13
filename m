From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Sun, 12 Nov 2006 23:46:15 -0800 (PST)
Message-ID: <20061112.234615.95058980.davem@davemloft.net>
References: <200611101609.21333@strip-the-willow>
	<20061110.143801.39158000.davem@davemloft.net>
	<200611130734.49700@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:922
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754232AbWKMHqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 02:46:22 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611130734.49700@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 07:34:48 +0000

> Quoting David Miller:
> |  
> |  I can't apply any of this Gerrit.
> |  
> |  What makes net/ipv4/udplite.c get built at all?  I see no
> |  changes to net/ipv4/Makefile, so you must have stuffed up
> |  the generation of your patches.
> This is a misunderstanding: udplite.o will never be built, 
> it is #included in udp.c. Witness
> 
> ==> net/ipv4/udp.c, line 1727:
> 	
> 	/* the extensions for UDP-Lite (RFC 3828) */
> 	#include "udplite.c"
> 
> ==> net/ipv6/udp.c, line 1009:
> 	/* the extensions for UDP-Lite (RFC 3828) */
> 	#include "udplite.c"

Sorry I misread this.

I'm not a huge fan of source file inclusion like this.
It's not a header file, it contains code.

Is there a way to build this as a seperate object somehow?
