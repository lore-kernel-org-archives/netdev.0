From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] dccp: allow probing of CCID-array length
Date: Fri, 12 Feb 2010 12:07:38 -0800 (PST)
Message-ID: <20100212.120738.189368103.davem@davemloft.net>
References: <20100208062028.GA5478@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48019
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756746Ab0BLUHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:07:24 -0500
In-Reply-To: <20100208062028.GA5478@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 8 Feb 2010 07:20:28 +0100

> This fixes a problem in the DCCP getsockopt() API: currently there is no way
> for a user to a priori know the number of built-in CCIDs, other than trying
> DCCP_SOCKOPT_AVAILABLE_CCIDS in a loop, incrementing the option length until
> EINVAL is no longer returned.
> 
> This patch truncates the array to the user-provided length. No copy is made
> when the length is <= 0.
> 
> Due to the length restriction in do_dccp_getsockopt() to sizeof(int), the
> minimum array length remains 4, which is a reasonable default (only 3
> CCIDs, CCID-2..4, are currently defined).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied to net-next-2.6, thanks Gerrit.
