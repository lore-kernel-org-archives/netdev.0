From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Tue, 24 May 2011 23:59:23 +0200
Message-ID: <20110524215923.GA20138@rere.qmqm.pl>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
 <20110519100331.GA25103@rere.qmqm.pl>
 <20110524091437.GA10779@rere.qmqm.pl>
 <20110524.153930.610330240390616957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48101 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529Ab1EXV7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 17:59:24 -0400
Content-Disposition: inline
In-Reply-To: <20110524.153930.610330240390616957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 03:39:30PM -0400, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Tue, 24 May 2011 11:14:37 +0200
>=20
> > On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=B3 Miros=B3aw wrote=
:
> >> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote:
> >> > You guys really need to sort this out properly.
> >> > Please resubmit whatever final solution is agreed upon.
> >> I noticed that v2.6.39 was tagged today. We should definitely remo=
ve
> >> NETIF_F_COMPAT so it won't bite us in the future. The other patch =
that
> >> fixes ethtool_ops->set_flags compatibility is a bugfix, so it shou=
ld go
> >> in - if we decide that the SFEATURES compatibility should be remov=
ed
> >> it won't matter.
> >>=20
> >> Ben, do you agree?
> > Ping?
> > http://patchwork.ozlabs.org/patch/95552/
> > (this is a bugfix, so should go to stable)
> >=20
> > http://patchwork.ozlabs.org/patch/95753/
> > (removes ETHTOOL_F_COMPAT; this we need to decide on)
> You and Ben are still arguing over details.
>=20
> I want fresh versions of these patches (yes, both of them) once
> all of the issues are resolved.

We could just wait for 2.6.40 and pretend this code part never existed.=
 ;-)

I'll rebase the first patch tomorrow. Without it the compatibility in
ETHTOOL_SFEATURES for non-converted drivers is busted wrt set_flags.

Best Regards,
Micha=B3 Miros=B3aw
