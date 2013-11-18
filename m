From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Mon, 18 Nov 2013 10:22:55 +0100
Message-ID: <20131118092255.GX31491@secunet.com>
References: <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
 <20131115.174426.1448825246187940374.davem@davemloft.net>
 <20131115233919.GB11450@pomac.netswarm.net>
 <20131115.185755.1752342950675745464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pomac@demius.net, bhelgaas@google.com, pomac@vapor.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org, alex.aring@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33059 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab3KRJXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 04:23:07 -0500
Content-Disposition: inline
In-Reply-To: <20131115.185755.1752342950675745464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 06:57:55PM -0500, David Miller wrote:
> From: Ian Kumlien <pomac@demius.net>
> Date: Sat, 16 Nov 2013 00:39:19 +0100
> 
> > On Fri, Nov 15, 2013 at 05:44:26PM -0500, David Miller wrote:
> >> From: Bjorn Helgaas <bhelgaas@google.com>
> >> Date: Fri, 15 Nov 2013 15:29:53 -0700
> >> 
> >> > [+cc David, Eric, Alex, netdev]
> >> > 
> >> > Alex reported a similar issue at
> >> > http://marc.info/?l=linux-netdev&m=138355719901790&w=4
> >> 
> >> Fixed by:
> >> 
> >> commit 84502b5ef9849a9694673b15c31bd3ac693010ae
> >> Author: Steffen Klassert <steffen.klassert@secunet.com>
> >> Date:   Wed Oct 30 11:16:28 2013 +0100
> > 
> > Cherry-picked, compiled and preparing for reboot - thanks!
> > 
> > Shouldn't this be queued up in stable sometime soonish?
> > 
> > (Sorry for the change of email address, i had forgot to switch the
> > configurations in mutt)
> 
> Steffen is in charge of IPSEC -stable submissions, please ask him
> :-)

It was intended for v3.12 but the release came before it was merged
into the manline. So yes, it should go to the v3.12 stable tree.

I've always did stable submissions just by marking them as a
candidate for stable, this did not happen here because I hoped
it will make it into v3.12. It should apply cleanly to v3.12
stable, you could just pick it into you stable queue, or
alternatively I can submit to stable.
