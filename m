From: Michael Arndt <flexray4linux@scriptkiller.de>
Subject: Re: [PATCH] FlexRay: Allocate numbers for FlexRay communication
Date: Sat, 2 May 2009 18:32:29 +0200
Message-ID: <20090502163229.GY13310@m58s01.vlinux.de>
References: <20090430163825.GX13310@m58s01.vlinux.de> <49F9DFA1.30100@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Michael Arndt <flexray4linux@scriptkiller.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scriptkiller.de ([83.151.21.67]:57163 "EHLO m58s01.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755800AbZEBQca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2009 12:32:30 -0400
Content-Disposition: inline
In-Reply-To: <49F9DFA1.30100@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 07:28:01PM +0200, Oliver Hartkopp wrote:
> > I do not know why ETH_P_CAN has been chosen to be 0x000C
> 
> perhaps because of 'C'AN ?

Ok, thanks for the hint. So I should maybe choose 0x000F :)

> - What is the technical background?
> - Is there any documentation?

My goal is to bring (low-cost) FlexRay communication to Linux. There is
some documentation of the project which I will hopefully put up soon.

> - Do you need realtime?

Would be nice, but will probably be hard to do. Currently only sending/
receiving in pre-configured message buffers is possible, so the real
low level stuff will be handled in hardware (in the FlexRay Communication
Controller [CC]).

> - What hardware is supported?

See below. But the major goal is to provide a common framework for
all hardware, similar to the SocketCAN implementation.
Unfortunately I do not have several thousand Euros to spend for
commercially available solutions [1, 2]. I also bet their drivers
(if available at all for Linux; seems that only TZM has one)
will be incompatible with each other and are closed source.

> I bet there's no Flexray hardware on the market that can be attached on a
> serial line like there are for low-cost CAN adaptors, right?

Actually, I have a working prototype of such an (limited) adapter lying on
my desk right now.

Regards,

Michael


[1] http://www.vector.com/
[2] http://www.tzm.de/

