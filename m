From: David Miller <davem@davemloft.net>
Subject: Re: PATCH tcp_init_wl / tcp_update_wl argument cleanup
Date: Mon, 02 Mar 2009 22:43:33 -0800 (PST)
Message-ID: <20090302.224333.03623374.davem@davemloft.net>
References: <49AA657B.5030904@gmail.com>
	<20090302.031401.177327405.davem@davemloft.net>
	<49AC1E03.2000900@ceid.upatras.gr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xantzis@ceid.upatras.gr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60680
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753095AbZCCGnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:43:51 -0500
In-Reply-To: <49AC1E03.2000900@ceid.upatras.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hantzis Fotis <xantzis@ceid.upatras.gr>
Date: Mon, 02 Mar 2009 19:57:23 +0200

> David Miller wrote:
> > From: "ithilgore.ryu.L@gmail.com" <ithilgore.ryu.l@gmail.com>
> > Date: Sun, 01 Mar 2009 12:37:47 +0200
> >
> >   
> >> The above functions from include/net/tcp.h have been defined with an
> >> argument that they never use. The argument is 'u32 ack' which is never
> >> used inside the function body, and thus it can be removed. The rest of
> >> the patch involves the necessary changes to the function callers of the
> >> above two functions.
...
> Sorry for not complying with the guidelines on the previous submission.
> I am resending the patch properly this time:
> 
> Signed-off-by: Hantzis Fotis <xantzis@ceid.upatras.gr>

Applied, thanks.
