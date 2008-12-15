From: David Miller <davem@davemloft.net>
Subject: Re: IFF_RUNNING without carrier after reboot
Date: Sun, 14 Dec 2008 23:36:25 -0800 (PST)
Message-ID: <20081214.233625.36638431.davem@davemloft.net>
References: <20081214.222951.190945313.davem@davemloft.net>
	<E1LC7s0-0007qm-T3@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752016AbYLOHgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 02:36:24 -0500
In-Reply-To: <E1LC7s0-0007qm-T3@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 15 Dec 2008 18:28:00 +1100

> David Miller <davem@davemloft.net> wrote:
> >
> > The RUNNING state has no connection to link presence.
> > 
> > It just means that the device has been brought up by a
> > user configuration command like the ifconfig you ran.
> > 
> > It really means nothing else.
> 
> Well RUNNING did use to indicate carrier state.  In fact I didn't
> even know that it had changed until this email :)
> 
> This is the changeset which did it:

Yes, it was a bug and we fixed it more than 2 years ago.
Thanks for confirming :-)
