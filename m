From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 6 Nov 2006 01:37:41 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611060137020.25218@g5.osdl.org>
References: <1162780109.28571.273.camel@localhost.localdomain>
 <454EE943.6000603@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8399 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423629AbWKFJiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 04:38:16 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <454EE943.6000603@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 6 Nov 2006, Jeff Garzik wrote:
>
> This seems a bit ugly.  Could you add
> 
> 	#define readq readq
> 
> to your platform instead?

Heartily agreed. MUCH better than adding unrelated #if defined() stuff, 
whether arch-related or otherwise.

		Linus
