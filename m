From: Florian Westphal <fw@strlen.de>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 12:11:44 +0200
Message-ID: <20140523101144.GH24523@breakpoint.cc>
References: <6zlhtsvnqp.fsf@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jonas Bonn <jonas@southpole.se>
To: Niels =?iso-8859-15?Q?M=F6ller?= <nisse@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60681 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbaEWKLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 06:11:46 -0400
Content-Disposition: inline
In-Reply-To: <6zlhtsvnqp.fsf@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Niels M=F6ller <nisse@southpole.se> wrote:
> So now I'm trying to figure out what's the Right Way to enable traffi=
c
> generations with a large number of source addresses, to possibly reti=
re
> the proprietary kernel module. I see a couple of different approaches=
:

[..]

> 3. Just set the desired local address with the bind call. Currently,
>    this gives an EADDRNOTAVAIL error, so the first step would be some
>    option to allow arbitrary source addresses.

See 'Making non-local sockets work' in Documentation/networking/tproxy.=
txt
