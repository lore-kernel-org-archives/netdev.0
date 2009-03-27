From: David Miller <davem@davemloft.net>
Subject: Re: [patch] xfrm: spin_lock() should be spin_unlock() in
 xfrm_state.c
Date: Fri, 27 Mar 2009 00:24:13 -0700 (PDT)
Message-ID: <20090327.002413.94445791.davem@davemloft.net>
References: <20090326185845.2c5719b4@dhcp-100-2-144.bos.redhat.com>
	<20090327011654.GA24848@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbZC0HYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:24:25 -0400
In-Reply-To: <20090327011654.GA24848@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 27 Mar 2009 09:16:54 +0800

> On Thu, Mar 26, 2009 at 06:58:45PM -0400, Chuck Ebbert wrote:
> > xfrm: spin_lock() should be spin_unlock() in xfrm_state.c
> > 
> > spin_lock() should be spin_unlock() in xfrm_state_walk_done().
> > 
> > caused by:
> > commit 12a169e7d8f4b1c95252d8b04ed0f1033ed7cfe2
> > "ipsec: Put dumpers on the dump list"
> > 
> > Reported-by: Marc Milgram <mmilgram@redhat.com>
> > Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
 ...
> Good catch!

Applied and queued to -stable.

I can't believe nobody hit this in all of this time :-)
