From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Tue, 25 Feb 2014 20:16:02 +0100
Message-ID: <20140225191602.GD9965@breakpoint.cc>
References: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
 <20140220095934.GF32371@secunet.com>
 <530C3B07.3090406@windriver.com>
 <1393348547.14067.18.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56170 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752039AbaBYTQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 14:16:15 -0500
Content-Disposition: inline
In-Reply-To: <1393348547.14067.18.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> wrote:
> > On 2014=E5=B9=B402=E6=9C=8820=E6=97=A5 17:59, Steffen Klassert wrot=
e:
> > > For now I think we should just refuse to do anything if someone t=
ries
> > > to configure ipsec with 32 bit tools on a 64 bit machine.
> >=20
> > I'm fine with your point, and it would be a good choice to inform u=
ser about
> > this behavior other than just creating non-working SA and SP for us=
er.

It might be better to try to revive
http://thread.gmane.org/gmane.linux.network/157118/focus=3D157122

which adds full compat support.
