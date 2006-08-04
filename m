From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 04 Aug 2006 06:16:03 -0400
Message-ID: <1154686563.5187.43.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au>
	 <20060804083734.GA16082@gondor.apana.org.au>
	 <20060804101017.GA17393@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:47521 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161129AbWHDKQG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:16:06 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8wit-0008M9-Oz
	for netdev@vger.kernel.org; Fri, 04 Aug 2006 06:16:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804101017.GA17393@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 20:10 +1000, Herbert Xu wrote:
> On Fri, Aug 04, 2006 at 06:37:34PM +1000, herbert wrote:
> > 
> > [NETDRV] e1000: Fix potential tx wake up race
> 
> Oops, I completely looked through netpoll_trap.  Hmm, someone should
> really move the ifdef into netpoll_trap.  Stephen?
> 
> BTW, who uses netpoll_set_trap anyway? There seems to be no user in
> the kernel tree.  Where's Adrian Bunk :)

You sure you wanna wake him up? ;->

I still have my setup intact, so i will give this a whirl in about 3-4
hours. It does look promising - an atomic should be a lot cheaper than a
lock. Thanks Herbert.

cheers,
jamal


