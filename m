From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 28 Sep 2007 18:27:19 +0200
Message-ID: <1190996839.18681.68.camel@chaos>
References: <ygfr6kmev3i.fsf@janus.isnogud.escape.de>
	 <20070925083303.6c1f7701@freepuppy.rosehill>
	 <ygfejgmea00.fsf@janus.isnogud.escape.de>
	 <20070925.140910.41653604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kaber@trash.net, joe@perches.com,
	oliver@hartkopp.net, oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:53976 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754122AbXI1Q1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 12:27:23 -0400
In-Reply-To: <20070925.140910.41653604.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-25 at 14:09 -0700, David Miller wrote:
> > > Then please make all exported symbols marked EXPORT_SYMBOL_GPL to make
> > > sure that the other CAN protocol can not reuse your infrastructure.
> > 
> > We don't want to force other CAN protocol implementations to be GPL
> > also.  AFAIR from discussions on LKML, it was mostly agreed upon that
> > this decision is up to the authors of code.
> 
> To a certain extent, yes.
> 
> However, the core issue is whether anyone who uses the symbol
> is creating a derivative work.  If it is pretty clear that this
> is the case, you really should mark the exported symbols GPL.
> 
> In my opinion, in this case it is pretty clear that any use of
> these new symbols would be a derivative work and therefore they
> all should be marked GPL.

Hmm, the code in question is dual licensed. So it's not that clear to
me. 

But it's a legal grey area anyway if somebody loads non GPL code into
the kernel, though IANAL and we can spend years on this discussion.

I'm not inclined either way and we really should not make this a
religious question whether that code goes in or not, especially not when
we granted the mac80211 to export everything w/o _GPL suffix not too
long ago.

Thanks,

	tglx


