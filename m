From: alex@pilosoft.com
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Fri, 23 Apr 2004 10:15:54 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0404231006440.8887-100000@paix.pilosoft.com>
References: <1082640135.1059.93.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264824AbUDWOSW@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1082640135.1059.93.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

> And for something like a huge download to just regular joe, this is more
> of a nuisance assuming some kiddie has access between you and the
> server. OTOH, long lived BGP sessions are affected assuming you are
> going across hostile path to your peer.
Again - no hostile path necessary. Attack is brute-force and does not rely 
on MITM.

> So whats all this ado about nothing? Local media made it appear we are
> all about to die.
Pretty much.
> 
> Is anyone working on some fix?
In networking world, there was a craze of enabling TCP-MD5 for BGP
sessions reacting to this attack. There is alternative solution, "TTL
hack", relying that most BGP sessions are between directly-connected 
routers, so if connection originator sets TTL to 255 and receiver verifies 
that TTL on incoming packet is 255, you can be reasonably certain that the 
packet was sent by someone directly connected to you. ;)

-alex
