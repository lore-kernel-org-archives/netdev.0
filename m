From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 11:28:11 +0100
Message-ID: <1367490491.5106.137.camel@deadeye.wl.decadent.org.uk>
References: <20130502.041625.412316202038784117.davem@davemloft.net>
	 <20130502083619.GA22010@macbook.localnet> <87d2t9bvj1.fsf@nemi.mork.no>
	 <20130502.051727.949429506738234701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <bjorn@mork.no>, <kaber@trash.net>,
	<torvalds@linux-foundation.org>, <hayeswang@realtek.com>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28200 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab3EBK2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 06:28:16 -0400
In-Reply-To: <20130502.051727.949429506738234701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 05:17 -0400, David Miller wrote:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Thu, 02 May 2013 11:06:42 +0200
>=20
> > Adding the new netdev features will make it go from 1 to 2:
>=20
> We already had more than 31 feature bits before Patrick's
> changes, and I'm pretty sure this was the case when we added
> that ethtool API.

It wasn't, but this should be OK.  Userland is supposed to query the
number of features using ETHTOOL_GSSET_INFO and then work out the numbe=
r
of words/blocks using FEATURE_BITS_TO_BLOCKS(). =20

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
