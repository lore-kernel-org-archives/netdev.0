From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 9 May 2007 11:21:32 +0200
Message-ID: <20070509092132.GB6976@xi.wantstofly.org>
References: <464034CF.20700@wpkg.org> <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com> <m3bqgv72sq.fsf@maximus.localdomain> <20070508155201.GA1251@xi.wantstofly.org> <m3hcqn5j0p.fsf@maximus.localdomain> <f1s2eu$26p$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcus Better <marcus@better.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:51597 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427AbXEIJVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 05:21:34 -0400
Content-Disposition: inline
In-Reply-To: <f1s2eu$26p$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 10:58:06AM +0200, Marcus Better wrote:

> >> There _is_ an ARM BE version of Debian.
> >>
> >> It's not an official port, but it's not maintained any worse than
> >> the 'official' LE ARM Debian port is.
> 
> > Hmm... That changes a bit. Perhaps we should forget about
> > that LE thing then, and (at best) put that trivial workaround?
> 
> Please keep in mind that users are unlikely to install an unofficial port
> which lacks integration with the Debian infrastructure, security support
> and other services. The arm architecture (LE) is currently the third most
> popular in Debian, whereas I suspect (?) there are very few BE Debian
> systems out there.

Note that all of your arguments also apply to the experimental
EABI little-endian ARM port.

I.e.:
1. The EABI port is an unofficial port.
2. The EABI port is not integrated with the Debian infrastructure.
3. The EABI port lacks security support.

You could also argue that:
4. "There is no reason to use EABI -- old-ABI works just as well."
5. "The perceived floating point speedups that EABI gives are
   completely drowned out by the slowness of the rest of the system."
6. "A lot of programs assume old-ABI behavior, it is too much work
   to patch them all."

Does that mean that the Debian ARM people have their heads so far
up their collective asses that they think that every form of change
is bad and are unable to accept that some forms of change might be
for the better?

I think you've just summarised why I don't like working on Debian.
