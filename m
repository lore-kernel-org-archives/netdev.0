From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] dccp: Limit feature negotiation to connection
 setup phase
Date: Mon, 10 Nov 2008 13:15:15 -0800 (PST)
Message-ID: <20081110.131515.155716151.davem@davemloft.net>
References: <20081104.235652.27274000.davem@davemloft.net>
	<1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751016AbYKJVPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:15:16 -0500
In-Reply-To: <1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:11 +0100

> This patch limits feature-negotiation to the connnection-setup phase:
> 
>  1. Although it is theoretically possible to perform feature negotiation at any
>     time (and RFC 4340 supports this), in practice this is prohibitively complex,
>     as it requires to put traffic on hold for each new negotiation.
>  2. As a byproduct of restricting feature negotiation to connection setup, the
>     feature-negotiation retransmit timer is no longer required. This part is now
>     mapped onto the protocol-level retransmission.
>     Details indicating why timers are no longer needed can be found on
>     http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
> 	                                      implementation_notes.html
> 
> This patch disables anytime negotiation, subsequent patches work out full
> feature negotiation support for connection setup.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
