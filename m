From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/4] bnx2x: support classification config query
Date: Mon, 05 Dec 2011 21:59:19 -0800
Message-ID: <1323151159.19483.14.camel@joe2Laptop>
References: <1323150288-28153-1-git-send-email-mchan@broadcom.com>
	 <1323150288-28153-2-git-send-email-mchan@broadcom.com>
	 <1323150288-28153-3-git-send-email-mchan@broadcom.com>
	 <20111206.004629.1477080329086805790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51579 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751308Ab1LFF7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 00:59:20 -0500
In-Reply-To: <20111206.004629.1477080329086805790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 00:46 -0500, David Miller wrote:
> > +			DP(BNX2X_MSG_SP, "copied element number "
> > +				   "%d to address %p element was "
> > +				   "%pM\n", counter, next, pos->u.mac.mac);
> 
> Likewise.

Ideally, the format should be coalesced as well.

			DP(BNX2X_MSG_SP, "copied element number %d to address %p - element was %pM\n",
			   counter, next, pos->u.mac.mac);
