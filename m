From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 03 May 2013 07:11:29 +1000
Message-ID: <1367529089.4389.23.camel@pasglop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <20130501115103.58e40f37@kryten>
	 <1367375060.11020.24.camel@edumazet-glaptop>
	 <20130501035425.GD5221@bubble.grove.modra.org>
	 <1367384672.11020.34.camel@edumazet-glaptop>
	 <20130501081054.267a7851@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alan Modra <amodra@gmail.com>,
	Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40491 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760420Ab3EBVLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 17:11:49 -0400
In-Reply-To: <20130501081054.267a7851@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 08:10 -0700, Stephen Hemminger wrote:
> > These kind of errors are pretty hard to find, its a pity to spend
> time
> > on them.
> 
> There is a checkbin target inside arch/powerpc/Makefile
> Shouldn't a check be added there to block building kernel with known
> bad GCC versions?

In this case that makes it all GCC versions except the *very
latest* .... not practical.

I suppose we should try to make sure that at least the next batch of
enterprise distro get that fix on gcc side.

Ben.
