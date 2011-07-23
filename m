From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sat, 23 Jul 2011 09:37:43 -0700
Message-ID: <20110723093743.7c90b78f@nehalam.ftrdhcpuser.net>
References: <20110719180222.GA7509@midget.suse.cz>
	<20110722.010628.1678943945721626312.davem@davemloft.net>
	<20110722092159.GA20722@gondor.apana.org.au>
	<4E2ADB39.9070409@gmail.com>
	<20110723152724.GA11028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>, David Miller <davem@davemloft.net>,
	jbohac@suse.cz, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35977 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753046Ab1GWQhh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 12:37:37 -0400
In-Reply-To: <20110723152724.GA11028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Jul 2011 23:27:24 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Jul 23, 2011 at 04:31:21PM +0200, Nicolas de Peslo=FCan wrote=
:
> >
> > That being said, the time to renegotiate a network setup sounds ver=
y=20
> > short, compared to the time for a full suspend-migrate-resume cycle=
=2E I'm=20
> > not sure VM migration would really suffer from such renegotiation.
>=20
> Live migration certainly would suffer from multiple RTTs that
> result from renegotiation.
>=20
> Cheers,

Would it be possible to do live migration without dropping carrier
or setting interface down?
