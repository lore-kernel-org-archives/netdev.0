From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] dccp: Lockless integration of CCID
 congestion-control plugins
Date: Sun, 04 Jan 2009 21:45:55 -0800 (PST)
Message-ID: <20090104.214555.48754453.davem@davemloft.net>
References: <20090101104923.GA4269@gerrit.erg.abdn.ac.uk>
	<1230967849-9456-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57426
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750875AbZAEFpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 00:45:51 -0500
In-Reply-To: <1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Jan 2009 08:30:47 +0100

> Based on Arnaldo's earlier patch, this patch integrates the standardised
> CCID congestion control plugins (CCID-2 and CCID-3) of DCCP with dccp.ko:
> 
>  * enables a faster connection path by eliminating the need to always go 
>    through the CCID registration lock;
> 
>  * updates the implementation to use only a single array whose size equals
>    the number of configured CCIDs instead of the maximum (256);
> 
>  * since the CCIDs are now fixed array elements, synchronization is no
>    longer needed, simplifying use and implementation.
> 
> CCID-2 is suggested as minimum for a basic DCCP implementation (RFC 4340, 10);
> CCID-3 is a standards-track CCID supported by RFC 4342 and RFC 5348.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
