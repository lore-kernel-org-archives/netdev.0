From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 19 Feb 2009 14:56:13 +0300
Message-ID: <20090219115613.GB4551@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net> <499C2308.2000109@trash.net> <20090218150742.GA30490@ioremap.net> <alpine.LSU.2.00.0902181629300.8034@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:54935 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbZBSL4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 06:56:22 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902181629300.8034@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2009 at 04:30:03PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >As of IPv6 support - it could be fairly trivial, the only thing we need
> >is to dereference TCP header with the appropriate offset anf get don't
> >fragment bit (ipv6 does not have it, so we could check both entries).
> 
> But IPv6 can have Fragment Headers, serving about the same purpose.
> 
> >But... I do not have IPv6 network to test the changes (and definitely
> >did not have it 6 years ago), so it was never implemented :)
> 
> There exist lots of free VM solutions - and I think UML existed
> 6 years ago, too.

It is not that simple. IPv6 was never a out-of-the-box solution, and in
case of this module we either need to setup a router, or use ipv6-aware
application (fortunately telnet knows that in the recent distros).

-- 
	Evgeniy Polyakov
