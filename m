From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name
 instead of magic number 0
Date: Fri, 26 Jul 2013 13:56:10 -0700
Message-ID: <1374872170.2009.1.camel@joe-AO722>
References: <51EF79E6.9060309@gmail.com>
	 <1374649819.18818.5.camel@joe-AO722>
	 <20130726.135330.232525167518786234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shhuiw@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50890 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933189Ab3GZU4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 16:56:12 -0400
In-Reply-To: <20130726.135330.232525167518786234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 13:53 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 24 Jul 2013 00:10:19 -0700
> 
> > Probably be simpler, less confusing, and more normal style
> > to use a switch case.
> > 
> >       switch (mode) {
> >       case BOND_MODE_ROUNDROBIN:
> >               return "load balancing (round-robin)";
> >       case BOND_MODE_ACTIVEBACKUP:
> >               return "fault-tolerance (active-backup)";
> >       case BOND_MODE_XOR:
> >               return "load balancing (xor)";
> >       case BOND_MODE_BROADCAST;
> >               return "fault-tolerance (broadcast)";
> >       case BOND_MODE_8023AD:
> >               return "IEEE 802.3ad Dynamic link aggregation";
> >       case BOND_MODE_TLB:
> >               return "transmit load balancing";
> >       case BOND_MODE_ALB:
> >               return "adaptive load balancing";
> >       default:
> >               return "unknown";
> >       }
> 
> I have to say that I do not prefer this approach.
> 
> I have a good idea what the compiler ends up outputting for the above,
> and the "indexed table of strings" approach is much less code.

It has the benefit of not breaking if ever the
BOND_MODE_<foo> #defines are ever non-consecutive.
