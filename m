From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 13 Feb 2009 17:22:04 +0300
Message-ID: <20090213142204.GA27554@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net> <alpine.LSU.2.00.0902131448040.9310@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:45257 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760030AbZBMOWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2009 09:22:19 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902131448040.9310@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2009 at 02:51:48PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >> config NETFILTER_XT_MATCH_COMMENT
> >>         tristate  '"comment" match support'
> >>         depends on NETFILTER_ADVANCED
> >>         ---help---
> >
> >But I placed OSF into net/ipv4/netfilter/ipt_osf.c, should it be moved
> >into different location?
> 
> That would be preferable -> net/netfilter/xt_osf.c.

Ok, I will move it there.

> >> >proper offset (modulo of the option size).
> >> 
> >> What if optp is odd?
> >
> >It cant, header is fixed and every option length is also fixed (and its
> >size is checked).
> 
> This RFC-compliant ("An option may begin on any octet boundary.")
> option byte stream seems to produce an odd optp value:
> 
> 01 02 04 05 a0 00
> 
> or where did I go wrong?

OSF checks only MSS and timestamp options.

-- 
	Evgeniy Polyakov
