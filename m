From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rndis_host: Poll status channel before control channel
Date: Tue, 27 Apr 2010 18:01:38 -0700 (PDT)
Message-ID: <20100427.180138.56372092.davem@davemloft.net>
References: <1271718508.2197.12.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, john.carr@unrouted.co.uk,
	netdev@vger.kernel.org, vzeeaxwl@myfairpoint.net,
	herton@mandriva.com.br
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755074Ab0D1BBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 21:01:32 -0400
In-Reply-To: <1271718508.2197.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 20 Apr 2010 00:08:28 +0100

> Some RNDIS devices don't respond on the control channel until polled
> on the status channel.  In particular, this was reported to be the
> case for the 2Wire HomePortal 1000SW.
> 
> This is roughly based on a patch by John Carr <john.carr@unrouted.co.uk>
> which is reported to be needed for use with some Windows Mobile devices
> and which is currently applied by Mandriva.
> 
> Reported-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
> ---
> Note that this change hasn't yet been tested with any other RNDIS
> devices.  John, can you confirm whether this also handles the WinMob
> devices?

I haven't seen any other testing for this patch and I'm real hesitant
to apply something like this in that case.
