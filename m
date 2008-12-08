From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] dccp: Integration of dynamic feature activation -
 part 3 (client side)
Date: Mon, 08 Dec 2008 01:16:39 -0800 (PST)
Message-ID: <20081208.011639.169128034.davem@davemloft.net>
References: <1228581657-6724-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbYLHJQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:16:38 -0500
In-Reply-To: <1228581657-6724-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:53 +0100

> This integrates feature-activation in the client:
> 
>  1. When dccp_parse_options() fails, the reset code is already set; request_sent\
>     _state_process() currently overrides this with `Packet Error', which is not
>     intended - changed to use the reset code supplied by dccp_parse_options().
> 
>  2. When feature negotiation fails, the socket should be marked as not usable,
>     so that the application is notified that an error occurred. This is achieved
>     by a new label 'unable_to_proceed': generating an error code of `Aborted',
>     setting the socket state to CLOSED, returning with ECOMM in sk_err.
> 
>  3. Avoids parsing the Ack twice in Respond state by not doing option processing
>     again in dccp_rcv_respond_partopen_state_process (as option processing has
>     already been done on the request_sock in dccp_check_req).
> 
> Since this addresses congestion-control initialisation, a corresponding
> FIXME has been removed.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
