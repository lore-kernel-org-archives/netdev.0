From: David Miller <davem@davemloft.net>
Subject: Re: [RTNL]: Validate hardware and broadcast address attribute for
 RTM_NEWLINK
Date: Sat, 23 Feb 2008 19:55:08 -0800 (PST)
Message-ID: <20080223.195508.158721987.davem@davemloft.net>
References: <47BEC89E.9030909@trash.net>
	<20080222133135.GC20815@postel.suug.ch>
	<47BECF26.6030805@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755861AbYBXDy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:54:27 -0500
In-Reply-To: <47BECF26.6030805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Feb 2008 14:33:26 +0100

> Thomas Graf wrote:
> > The reason I did it this way is to keep validate_linkmsg() generic
> > and make it possible to put validation code which must also apply
> > to new links (dev==NULL) into that function.
> 
> OK, thanks for the explanation.

Patch applied, thanks.
