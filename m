From: jamal <hadi@cyberus.ca>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: 23 Apr 2004 10:25:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082730332.1027.57.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0404231006440.8887-100000@paix.pilosoft.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Florian Weimer <fw@deneb.enyo.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: alex@pilosoft.com
In-Reply-To: <Pine.LNX.4.44.0404231006440.8887-100000@paix.pilosoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Clarification:
I think the latency of my earlier email introduced by probably netdev is
creating a lot of "hostile" responses to me ;-> I feel like i am in
hostile path here ;->
I sent that email a long time ago, seems like netdev or my ISP decided
to deliver it now and reordered the delivery. This has happened to me a 
few times before with netdev thats why i prefer to cc people whenever i
can (worst case they receive more than one message)
Consider that message obsolete. I know you can create this problem via
brute force as you explained in your later email (that showed up
yesterday).

cheers,
jamal

On Fri, 2004-04-23 at 10:15, alex@pilosoft.com wrote:
> > And for something like a huge download to just regular joe, this is more
> > of a nuisance assuming some kiddie has access between you and the
> > server. OTOH, long lived BGP sessions are affected assuming you are
> > going across hostile path to your peer.
> Again - no hostile path necessary. Attack is brute-force and does not rely 
> on MITM.
> 
> > So whats all this ado about nothing? Local media made it appear we are
> > all about to die.
> Pretty much.
> > 
> > Is anyone working on some fix?
> In networking world, there was a craze of enabling TCP-MD5 for BGP
> sessions reacting to this attack. There is alternative solution, "TTL
> hack", relying that most BGP sessions are between directly-connected 
> routers, so if connection originator sets TTL to 255 and receiver verifies 
> that TTL on incoming packet is 255, you can be reasonably certain that the 
> packet was sent by someone directly connected to you. ;)
> 
> -alex
> 
> 
