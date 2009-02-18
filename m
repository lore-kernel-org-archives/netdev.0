From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 16:30:03 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902181629300.8034@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net>
 <499C2308.2000109@trash.net> <20090218150742.GA30490@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090218150742.GA30490@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2009-02-18 16:07, Evgeniy Polyakov wrote:
>
>As of IPv6 support - it could be fairly trivial, the only thing we need
>is to dereference TCP header with the appropriate offset anf get don't
>fragment bit (ipv6 does not have it, so we could check both entries).

But IPv6 can have Fragment Headers, serving about the same purpose.

>But... I do not have IPv6 network to test the changes (and definitely
>did not have it 6 years ago), so it was never implemented :)

There exist lots of free VM solutions - and I think UML existed
6 years ago, too.
