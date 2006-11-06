From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 20:57:13 +1100
Message-ID: <1162807033.28571.313.camel@localhost.localdomain>
References: <1162780109.28571.273.camel@localhost.localdomain>
	 <454EE943.6000603@pobox.com>
	 <Pine.LNX.4.64.0611060137020.25218@g5.osdl.org>
	 <1162806168.28571.309.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0611060149120.25218@g5.osdl.org>
	 <1162806691.28571.311.camel@localhost.localdomain>
	 <454F0678.50706@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41951 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1423694AbWKFJ5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 04:57:23 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <454F0678.50706@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-06 at 04:55 -0500, Jeff Garzik wrote:
> Benjamin Herrenschmidt wrote:
> > On Mon, 2006-11-06 at 01:50 -0800, Linus Torvalds wrote:
> >> On Mon, 6 Nov 2006, Benjamin Herrenschmidt wrote:
> >>> Anyway, what do you think of Jeff proposal to just implement them as two
> >>> 32 bits operations ? My arch guy side screams at the idea, but if,
> >>> indeed, drivers generally cope fine with it, I suppose that's ok.
> >> Last I saw, that's how normal PCI will split the IO anyway, so I guess it 
> >> makes sense.
> > 
> > Hrm.. true indeed. I'll implement them that way for ppc32 then.
> 
> Bonus points if you want to find-and-kill where individual drivers did
> 
> 	#ifndef readq
> 	implement readq and writeq by hand...
> 	#endif

Yes, well, we would have to make sure all archs have them defined
first though, but I suppose I can have a look later this week, maybe
tomorrow. Shouldn't be too hard :)

Ben.



