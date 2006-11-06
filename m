From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 20:42:47 +1100
Message-ID: <1162806168.28571.309.camel@localhost.localdomain>
References: <1162780109.28571.273.camel@localhost.localdomain>
	 <454EE943.6000603@pobox.com>
	 <Pine.LNX.4.64.0611060137020.25218@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:31664 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1423645AbWKFJmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 04:42:55 -0500
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611060137020.25218@g5.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-06 at 01:37 -0800, Linus Torvalds wrote:
> 
> On Mon, 6 Nov 2006, Jeff Garzik wrote:
> >
> > This seems a bit ugly.  Could you add
> > 
> > 	#define readq readq
> > 
> > to your platform instead?
> 
> Heartily agreed. MUCH better than adding unrelated #if defined() stuff, 
> whether arch-related or otherwise.

I agree it's less ugly, though I still don't like it much :-)

Anyway, what do you think of Jeff proposal to just implement them as two
32 bits operations ? My arch guy side screams at the idea, but if,
indeed, drivers generally cope fine with it, I suppose that's ok.

Ben.


