From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Sun, 03 Aug 2008 01:23:19 -0700 (PDT)
Message-ID: <20080803.012319.78025424.davem@davemloft.net>
References: <20080731105522.GB7601@gondor.apana.org.au>
	<20080731123731.GB29176@xi.wantstofly.org>
	<20080731125903.GA8773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752816AbYHCIXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 04:23:19 -0400
In-Reply-To: <20080731125903.GA8773@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 31 Jul 2008 20:59:03 +0800

> On Thu, Jul 31, 2008 at 02:37:31PM +0200, Lennert Buytenhek wrote:
> >
> > Like this?
> 
> Yes that ought to do the trick.
> 
> > From: Lennert Buytenhek <buytenh@wantstofly.org>
> > Subject: [NET] use software GSO for SG+CSUM capable netdevices
> > 
> > If a netdevice does not support hardware GSO, allowing the stack to
> > use GSO anyway and then splitting the GSO skb into MSS-sized pieces
> > as it is handed to the netdevice for transmitting is likely still
> > a win as far as throughput and/or CPU usage are concerned, since it
> > reduces the number of trips through the output path.
> > 
> > This patch enables the use of GSO on any netdevice that supports SG.
> > If a GSO skb is then sent to a netdevice that supports SG but does not
> > support hardware GSO, net/core/dev.c:dev_hard_start_xmit() will take
> > care of doing the necessary GSO segmentation in software.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone!
