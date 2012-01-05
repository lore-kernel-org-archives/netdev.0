From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] cnic: Improve error recovery on bnx2x
 devices
Date: Thu, 05 Jan 2012 14:08:35 -0500 (EST)
Message-ID: <20120105.140835.846952184860620132.davem@davemloft.net>
References: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
	<1325715148-1371-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374Ab2AETIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:08:37 -0500
In-Reply-To: <1325715148-1371-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 4 Jan 2012 14:12:28 -0800

> When a bnx2x device encounters parity errors, it will not respond to all
> SPQ messages.  As a result, the shutdown sequence before reset can take
> a long time as the ulp drivers (bnx2i/bnx2fc) have to wait for timeout
> of all such messages.
> 
> To improve this scenario, when bnx2x returns error on the SPQ, we'll send
> an immediate response to the ulp drivers to avoid such lengthy timeouts.
> 
> Adjust the return code of relevant functions to return error only if
> the message cannot be sent on the SPQ so that we'll generate an error
> completion to the ulp drivers.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
