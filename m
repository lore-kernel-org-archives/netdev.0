From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 10:12:58 -0700
Message-ID: <20060804101258.220cd7ce@localhost.localdomain>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	<Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	<1154628302.3117.15.camel@rh4>
	<1154642918.5187.13.camel@jzny2>
	<1154650197.3117.32.camel@rh4>
	<20060804011027.GC12085@gondor.apana.org.au>
	<20060804083734.GA16082@gondor.apana.org.au>
	<20060804101017.GA17393@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, hadi@cyberus.ca,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63719 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161332AbWHDRQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 13:16:50 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804101017.GA17393@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Aug 2006 20:10:17 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Aug 04, 2006 at 06:37:34PM +1000, herbert wrote:
> > 
> > [NETDRV] e1000: Fix potential tx wake up race
> 
> Oops, I completely looked through netpoll_trap.  Hmm, someone should
> really move the ifdef into netpoll_trap.  Stephen?
> 
> BTW, who uses netpoll_set_trap anyway? There seems to be no user in
> the kernel tree.  Where's Adrian Bunk :)

I don't use netconsole. Jeff Moyer seems to be the main instigator of this.
