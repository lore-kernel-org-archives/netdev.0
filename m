From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 6 Nov 2006 01:50:08 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611060149120.25218@g5.osdl.org>
References: <1162780109.28571.273.camel@localhost.localdomain>
 <454EE943.6000603@pobox.com>  <Pine.LNX.4.64.0611060137020.25218@g5.osdl.org>
 <1162806168.28571.309.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10194 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423660AbWKFJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 04:50:15 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1162806168.28571.309.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 6 Nov 2006, Benjamin Herrenschmidt wrote:
>
> Anyway, what do you think of Jeff proposal to just implement them as two
> 32 bits operations ? My arch guy side screams at the idea, but if,
> indeed, drivers generally cope fine with it, I suppose that's ok.

Last I saw, that's how normal PCI will split the IO anyway, so I guess it 
makes sense.

		Linus
