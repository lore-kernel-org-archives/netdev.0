From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Thu, 27 Oct 2005 14:37:14 -0300
Message-ID: <200510271737.j9RHbEvf013516@laptop11.inf.utfsm.cl>
References: <jgarzik@pobox.com>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jketreno@linux.intel.com, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751316AbVJ0RjV@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: Message from Jeff Garzik <jgarzik@pobox.com>
   of "Wed, 26 Oct 2005 11:42:51 EDT." <435FA3FB.9030107@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
> Andi Kleen wrote:
> > On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:
> >
> >>Change this to printing out the message once, per kernel boot.
> > It doesn't do that. It prints it once every 2^32 calls. Also
> 
> ...which is effectively one per kernel boot
> 
> 
> > the ++ causes unnecessary dirty cache lines in normal operation.

> Not a hot path operation by any stretch of the imagination, so that's
fine.

Right. As the "++" is inside "if(!printed) { ... }" it clearly isn't ;-)
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
