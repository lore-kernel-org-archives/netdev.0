From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Tue, 24 May 2011 11:14:37 +0200
Message-ID: <20110524091437.GA10779@rere.qmqm.pl>
References: <20110516132807.1A89F13A6A@rere.qmqm.pl>
 <1305553066.19966.32.camel@localhost>
 <20110516142340.GA2980@rere.qmqm.pl>
 <20110516.140958.625993829749556424.davem@davemloft.net>
 <20110519100331.GA25103@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51321 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab1EXJOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 05:14:38 -0400
Content-Disposition: inline
In-Reply-To: <20110519100331.GA25103@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=B3 Miros=B3aw wrote:
> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote:
> > You guys really need to sort this out properly.
> > Please resubmit whatever final solution is agreed upon.
> I noticed that v2.6.39 was tagged today. We should definitely remove
> NETIF_F_COMPAT so it won't bite us in the future. The other patch tha=
t
> fixes ethtool_ops->set_flags compatibility is a bugfix, so it should =
go
> in - if we decide that the SFEATURES compatibility should be removed
> it won't matter.
>=20
> Ben, do you agree?

Ping?

http://patchwork.ozlabs.org/patch/95552/
(this is a bugfix, so should go to stable)

http://patchwork.ozlabs.org/patch/95753/
(removes ETHTOOL_F_COMPAT; this we need to decide on)

Best Regards,
Micha=B3 Miros=B3aw
