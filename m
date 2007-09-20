From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] revert "8139too: clean up I/O remapping"
Date: Thu, 20 Sep 2007 14:11:21 -0700 (PDT)
Message-ID: <20070920.141121.83408904.davem@davemloft.net>
References: <200709202055.l8KKtWn3002075@imap1.linux-foundation.org>
	<46F2DF03.1060501@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbXITVLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 17:11:21 -0400
In-Reply-To: <46F2DF03.1060501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 20 Sep 2007 16:58:43 -0400

> akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Revert git-netdev-all's 9ee6b32a47b9abc565466a9c3b127a5246b452e5.  Michal was
> > getting oopses.
> > 
> > Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/8139too.c |   50 +++++++++++++++++++++++-----------------
> >  1 file changed, 29 insertions(+), 21 deletions(-)
> 
> ACK -- DaveM, please remove or revert this patch.
> 
> It is incomplete, and not required just "nice to have."  I can easily 
> recreate later.

I'll yank this one out next time I rebase.
